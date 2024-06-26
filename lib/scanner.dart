import 'dart:convert';
import 'dart:io';
// import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:splash/custom_provider.dart';
import 'package:splash/dio_singleton.dart';
import 'package:splash/payment.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;
  QRViewController? controller;
  List allLocations = [];
  Dio dio = DioSingleton.dio;

  @override
  void initState() {
    super.initState();
    getAllLocations();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  getAllLocations() async {
    String apiLink = dotenv.env['API_LINK']!;
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": 'Bearer ${appState.accessToken}'
    };
    try {
      final response = await dio.post('${apiLink}Cafe/locationidname',
          options: Options(headers: headers));
      var data = jsonDecode(response.data);
      setState(() {
        allLocations = data.map((e) => e['location_name']).toList();
        allLocations.insert(0, 'Select Location');
        print(allLocations);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            shape: const Border(
                bottom: BorderSide(
                    color: Color.fromRGBO(112, 12, 121, 1), width: 2)),
            title: const Text(
              "Scan QR Code",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(112, 12, 121, 1),
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              icon: const Icon(Icons.arrow_back),
              color: const Color.fromRGBO(112, 12, 121, 1),
            ),
            actions: [
              PopupMenuButton(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.only(
                        left: 5, right: 5, top: 2, bottom: 2),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color.fromRGBO(112, 12, 121, 1),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(42, 4, 49, 0.4),
                            blurRadius: 3.0,
                            spreadRadius: 1.5,
                            offset: Offset(
                              1.5,
                              1.5,
                            ),
                          ),
                        ]),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            color: Colors.white,
                          ),
                          Text("Easy \nPay",
                              style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ]),
                  ),
                  itemBuilder: (context) {
                    var i = -1;
                    return allLocations.map<PopupMenuEntry<dynamic>>((e) {
                      if (e == 'Select Location') {
                        return PopupMenuItem<int>(child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                          return const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Color(0xFF700C79),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Select Location :",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF700C79)))
                              ]);
                        }));
                      }
                      i++;
                      return PopupMenuItem<dynamic>(
                          value: i,
                          child: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PaymentScreen(
                                            location: e,
                                          )),
                                );
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(e,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF700C79)))
                                  ]),
                            );
                          }));
                    }).toList();
                    // return [
                    //   PopupMenuItem<int>(child: StatefulBuilder(builder:
                    //       (BuildContext context, StateSetter setState) {
                    //     return const Row(
                    //         mainAxisAlignment: MainAxisAlignment.start,
                    //         children: [
                    //           Icon(
                    //             Icons.location_on,
                    //             color: Color(0xFF700C79),
                    //           ),
                    //           SizedBox(
                    //             width: 5,
                    //           ),
                    //           Text("Select Location :",
                    //               style: TextStyle(
                    //                   fontSize: 14,
                    //                   fontWeight: FontWeight.w600,
                    //                   color: Color(0xFF700C79)))
                    //         ]);
                    //   })),
                    //   PopupMenuItem<int>(
                    //       value: 0,
                    //       child: StatefulBuilder(builder:
                    //           (BuildContext context, StateSetter setState) {
                    //         return TextButton(
                    //           onPressed: () {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                   builder: (context) => const PaymentScreen(
                    //                         location: 'Thane Hub 1',
                    //                       )),
                    //             );
                    //           },
                    //           child: const Row(
                    //               mainAxisAlignment: MainAxisAlignment.start,
                    //               children: [
                    //                 SizedBox(
                    //                   width: 5,
                    //                 ),
                    //                 Text("Thane Hub 1",
                    //                     style: TextStyle(
                    //                         fontSize: 14,
                    //                         fontWeight: FontWeight.w600,
                    //                         color: Color(0xFF700C79)))
                    //               ]),
                    //         );
                    //       })),
                    //   PopupMenuItem<int>(
                    //       value: 1,
                    //       child: TextButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) => const PaymentScreen(
                    //                       location: 'Thane Hub 2',
                    //                     )),
                    //           );
                    //         },
                    //         child: const Row(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             children: [
                    //               SizedBox(
                    //                 width: 5,
                    //               ),
                    //               Text("Thane Hub 2",
                    //                   style: TextStyle(
                    //                       fontSize: 14,
                    //                       fontWeight: FontWeight.w600,
                    //                       color: Color(0xFF700C79)))
                    //             ]),
                    //       )),
                    //   PopupMenuItem<int>(
                    //       value: 2,
                    //       child: TextButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) => const PaymentScreen(
                    //                       location: 'HO',
                    //                     )),
                    //           );
                    //         },
                    //         child: const Row(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             children: [
                    //               SizedBox(
                    //                 width: 5,
                    //               ),
                    //               Text("HO",
                    //                   style: TextStyle(
                    //                       fontSize: 14,
                    //                       fontWeight: FontWeight.w600,
                    //                       color: Color(0xFF700C79)))
                    //             ]),
                    //       )),
                    // ];
                  })
            ]),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildQRView(context),
            Positioned(top: 10, child: buildControlButtons()),
          ],
        ),
      ));

  Widget buildControlButtons() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white24,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Icon(
                      snapshot.data! ? Icons.flash_on : Icons.flash_off);
                } else {
                  return Container();
                }
              },
            ),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
          IconButton(
            icon: FutureBuilder(
              future: controller?.getCameraInfo(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return const Icon(Icons.switch_camera);
                } else {
                  return Container();
                }
              },
            ),
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
          )
        ],
      ));

  Widget buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: const Color.fromARGB(255, 112, 12, 121),
        borderRadius: 10,
        borderLength: 20,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);
    controller.scannedDataStream.listen((barcode) {
      controller.pauseCamera();
      switch (barcode.code) {
        case '5466467':
          this.barcode = null;
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const PaymentScreen(location: 'Thane Hub 1')))
              .then((value) => controller.resumeCamera());
        case '6543256':
          this.barcode = null;
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const PaymentScreen(location: 'Thane Hub 2')))
              .then((value) => controller.resumeCamera());
        case '8765467':
          this.barcode = null;
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const PaymentScreen(location: 'HO')))
              .then((value) => controller.resumeCamera());
        default:
      }
    });
  }
}
