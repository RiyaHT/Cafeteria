import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:splash/custom_provider.dart';
import 'package:timer_button/timer_button.dart';
import 'package:http/http.dart' as https;

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<StatefulWidget> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<Widget> otpInputArray = [];
  List otp = ['', '', '', ''];
  bool isVerified = false;
  int buttonCounter = 3;

  @override
  void initState() {
    super.initState();
    bool first = true;
    bool last = false;
    for (int i = 0; i < 4; i++) {
      if (i != 0) {
        first = false;
      }

      if (i == 3) {
        last = true;
      }

      otpInputArray.add(
          _textFieldOTP(first: first, last: last, index: i, context: context));
    }
  }

  Future<void> resendOTP(context) async {
    setState(() {
      isVerified = true;
    });
    final appState = Provider.of<AppState>(context, listen: false);
    try {
      final response = await https.post(
          Uri.parse(
            'https://cafe.sbigeneral.in/Cafe/triggerlambda',
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Accept": "application/json",
            "Authorization": 'Bearer ${appState.accessToken}'
          },
          body: appState.employeeNo);
      setState(() {
        isVerified = false;
      });
      var otp = response.body.split(' ')[3];
      appState.updateVariables(
        otp: int.parse(otp),
      );
    } catch (error) {
      setState(() {
        isVerified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Invalid OTP. Please try again!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));
    }
  }

  // Future<void> createUser(context) async {
  //   setState(() {
  //     isVerified = true;
  //   });

  //   final appState = Provider.of<AppState>(context, listen: false);
  //   Map<String, dynamic> post = {'EmployeeId': appState.employeeNo};
  //   String apiLink = dotenv.env['API_LINK']!;
  //   String key = generateRandomKey();
  //   String base64iv = generateRandomIV();
  //   String result = aesGcmEncryptJson(jsonEncode(post), key, base64iv);
  //   Map<String, dynamic> headers = {
  //     'Content-Type': 'application/json; charset=UTF-8',
  //     "Accept": "application/json",
  //     "Authorization": 'Bearer ${appState.accessToken}',
  //   };
  //   Map<String, dynamic> postData = {
  //     "resultData": result,
  //     "key": key,
  //     "base64IV": base64iv,
  //   };
  //   final response = await DioSingleton.dio.post('${apiLink}Cafe/generateOtp',
  //       data: postData, options: Options(headers: headers));
  //   if (response.statusCode == 200) {
  //     // var data = jsonDecode(response.data);
  //     // var decryptedData = aesGcmDecryptJson(response.data, key, base64iv);
  //     // var data = jsonDecode(decryptedData);
  //     setState(() {
  //       isVerified = false;
  //     });
  //     appState.updateVariables(
  //       // otp: data['otp'],
  //       otp: 4321,
  //     );
  //     Navigator.pushNamed(context, '/mpin');
  //   } else {
  //     setState(() {
  //       isVerified = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: const Text("Employee ID or E-mail ID Doesn't Exist"),
  //         action: SnackBarAction(
  //           label: ' Cancel',
  //           onPressed: () {},
  //         )));

  //     throw Exception('Failed to create album.');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          Container(
            constraints: const BoxConstraints.expand(),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
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
                children: <Widget>[
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
                            'assets/images/verified.jpg',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Verification',
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
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 35.0, right: 35.0, top: 25, bottom: 15),
                      child: Container(
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(42, 4, 49, 0.4),
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 2.0, //extend the shadow
                                  offset: Offset(
                                    3.0, // Move to right  horizontally
                                    3.0, // Move to bottom Vertically
                                  ),
                                ),
                              ]),
                          child: Column(children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 35),
                              child: Text(
                                'Please enter the 4-digit OTP that was sent to your Registered phone number (${'XXX-XXX-' + appState.mobileNumber.substring(6)} ) .',
                                maxLines: 4,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 35, bottom: 15),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: otpInputArray),
                            ),
                            Column(children: [
                              SizedBox(
                                height: 38,
                                width: 360,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 112, 12, 121),
                                      elevation: 10, // Elevation
                                      shadowColor: Colors.purple[300],
                                    ),
                                    child: const Text(
                                      'Verify',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: buttonCounter > 0
                                        ? () async {
                                            if (int.parse(otp.join('')) ==
                                                appState.otp) {
                                              Navigator.pushReplacementNamed(
                                                context,
                                                '/mpin',
                                              );
                                            } else {
                                              setState(() {
                                                if (buttonCounter > 0) {
                                                  buttonCounter--;
                                                }
                                              });
                                              buttonCounter == 0
                                                  ? Navigator
                                                      .pushReplacementNamed(
                                                          context, '/one')
                                                  : ScaffoldMessenger.of(
                                                          context)
                                                      .showSnackBar(SnackBar(
                                                          content: const Text(
                                                              "Invalid OTP. Please try again! "),
                                                          action:
                                                              SnackBarAction(
                                                            label: ' Cancel',
                                                            onPressed: () {},
                                                          )));
                                            }
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 10, 15, 20),
                                  child: Text(
                                      'Only $buttonCounter attempts left!')),
                            ]),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    " Didn't receive an otp? ",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                  ),
                                  TimerButton(
                                    label: "Resend OTP",
                                    timeOutInSeconds: 30,
                                    resetTimerOnPressed: true,
                                    onPressed: () {
                                      resendOTP(context);
                                    },
                                    buttonType: ButtonType.textButton,
                                    disabledColor: Colors.white,
                                    color: Colors.transparent,
                                    activeTextStyle: const TextStyle(
                                        color: Colors.blue, fontSize: 12),
                                    disabledTextStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ]),
                            const SizedBox(
                              height: 15,
                            ),
                            // Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     children: [
                            //       TimerButton(
                            //         label:
                            //             "Click here to send OTP on registered mobile number!",
                            //         timeOutInSeconds: 30,
                            //         resetTimerOnPressed: true,
                            //         onPressed: () {
                            //           resendOTP(context);
                            //         },
                            //         buttonType: ButtonType.textButton,
                            //         disabledColor: Colors.white,
                            //         color: Colors.transparent,
                            //         activeTextStyle: const TextStyle(
                            //             color: Colors.blue, fontSize: 12),
                            //         disabledTextStyle: const TextStyle(
                            //             color: Colors.grey, fontSize: 12),
                            //       ),
                            //     ]),
                            const SizedBox(
                              height: 15,
                            ),
                          ]))),
                ],
              ),
            )),
          ),
          isVerified
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
  }

  _textFieldOTP({required bool first, last, context, index}) {
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
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.isEmpty && first == false) {
              FocusScope.of(context).previousFocus();
            }
            otp[index] = value;
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: const Offstage(),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.purple),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
