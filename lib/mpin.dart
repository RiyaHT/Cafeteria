import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash/crypto_utils.dart';
import 'package:splash/custom_provider.dart';
import 'dio_singleton.dart';
import 'home.dart';
import 'dart:convert';
import 'dart:async';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});
  @override
  State<StatefulWidget> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String phoneNumber = '';
  List<dynamic> confirmPin = ['', '', '', ''];
  List<dynamic> codePin = ['', '', '', ''];
  final childrenOTP = <Widget>[];
  final childrenOTP2 = <Widget>[];
  bool _codeNotEqual = false;
  Widget textWidget = const Text('');
  int userId = 0;
  bool isValidating = false;
  Dio dio = DioSingleton.dio;

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 4; i++) {
      bool first = true;
      bool last = false;

      if (i == 3) {
        last = true;
      }

      if (i != 0) {
        first = false;
      }

      childrenOTP.add(
          _textFieldPIN(first: first, last: last, context: context, index: i));

      childrenOTP2.add(_textFieldPIN(
          first: first,
          last: last,
          context: context,
          index: i,
          isConfirm: true));
    }
  }

  Widget getTextWidget() {
    if (_codeNotEqual) {
      return const Text('asdasdsa');
    }
    return const Text('');
  }

  postMpin(String pin, mobileNumber) async {
    setState(() {
      isValidating = true;
    });
    Map<String, dynamic> post = {'mobileNo': mobileNumber, 'mpin': pin};
    String key = generateRandomKey();
    String base64iv = generateRandomIV();
    String result = aesGcmEncryptJson(jsonEncode(post), key, base64iv);
    String apiLink = dotenv.env['API_LINK']!;
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, dynamic> postData = {
      "encryptedData": result,
      "key": key,
      "base64IV": base64iv,
    };

    Map<String, dynamic> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": 'Bearer ${appState.accessToken}',
    };
    final response = await dio.post('${apiLink}Cafe/postMPIN2',
        data: postData, options: Options(headers: headers));
    // var decryptedData = aesGcmDecryptJson(response.data, key, base64iv);
    // // final Map<String, dynamic> data = jsonDecode(decryptedData);
    if (response.statusCode == 200) {
      setState(() {
        isValidating = false;
      });
      _prefs.then((SharedPreferences pref) => {
            pref.setInt('puserId', int.parse(response.data.split(' ')[6])),
            pref.setString('phoneNumber', appState.mobileNumber),
            pref.setString('employeeNo', appState.employeeNo),
            pref.getInt('puserId'),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
          });
    } else {
      setState(() {
        isValidating = false;
      });
      appState.showTechnicalError(context);
    }
  }

  _textFieldPIN(
      {required bool first, last, context, isConfirm = false, index}) {
    return SizedBox(
      height: 85,
      child: AspectRatio(
        aspectRatio: 0.6,
        child: TextField(
          autofocus: true,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          onChanged: (value) {
            if (isConfirm) {
              confirmPin[index] = value;
              if (codePin.join('') != confirmPin.join('')) {
                textWidget = const Text(
                  ' Mpin Does not match',
                  style: TextStyle(color: Colors.red),
                );
                setState(() {
                  _codeNotEqual = true;
                });
              } else {
                setState(() {
                  _codeNotEqual = false;
                });
                textWidget = Text('');
              }
            } else {
              codePin[index] = value;
            }
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.isEmpty && first == false) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: const InputDecoration(
            counter: Offstage(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.black12),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: Colors.purple,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, _) {
      return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(children: [
            Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  tileMode: TileMode.mirror,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(112, 12, 121, 0.55),
                    Color.fromRGBO(63, 166, 235, 0.55)
                  ],
                ),
              ),
              child: Center(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.purple,
                          radius: 70,
                          child: CircleAvatar(
                            radius: 68,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                              'assets/images/mpin.jpg',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Set Up MPIN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Enter a 4-Digit MPIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 35.0, right: 35.0, top: 25, bottom: 15),
                        child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(15, 35, 10, 15),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Enter 4-Digit MPIN',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromRGBO(112, 12, 121, 1),
                                        ),
                                      ),
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: childrenOTP,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(15, 10, 10, 15),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Confirm MPIN',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromRGBO(112, 12, 121, 1),
                                        ),
                                      ),
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0, bottom: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: childrenOTP2,
                                ),
                              ),
                              textWidget,
                              Column(children: [
                                SizedBox(
                                  height: 65,
                                  width: 360,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0,
                                        right: 15.0,
                                        top: 15,
                                        bottom: 15),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 112, 12, 121),
                                        elevation: 10, // Elevation
                                        shadowColor: Colors.purple[300],
                                      ),
                                      child: const Text(
                                        'Submit',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () {
                                        if (confirmPin.join('') ==
                                            codePin.join('')) {
                                          if (confirmPin.join('') != '' &&
                                              codePin.join('') != '') {
                                            postMpin(codePin.join(''),
                                                appState.mobileNumber);
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(
                                height: 35,
                              ),
                            ]))),
                  ],
                ),
              )),
            ),
            isValidating
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.5)),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          const Text('Please Wait...',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF700C79))),
                          const SizedBox(
                            height: 10,
                          ),
                          LoadingAnimationWidget.threeArchedCircle(
                            color: const Color.fromRGBO(112, 12, 121, 1),
                            size: 50,
                          ),
                        ])),
                  )
                : Container()
          ]));
    });
  }
}
