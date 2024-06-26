import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash/crypto_utils.dart';
import 'dart:convert';
import 'dart:async';
import 'package:splash/custom_provider.dart';
import 'package:splash/dio_singleton.dart';
import 'lock.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String phoneNumber = '';
  String mPin = '';
  final _formKey = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();
  bool isFocus = false;
  bool passwordVisible = true;
  bool isValidating = false;
  int buttonCounter = 5;
  Dio dio = DioSingleton.dio;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isFocus = true;
      } else {
        isFocus = false;
      }
      setState(() {});
    });
    _prefs.then((SharedPreferences prefs) async {});
  }

  validateMpin() async {
    setState(() {
      isValidating = true;
    });
    SharedPreferences prefs = await _prefs;
    final appState = Provider.of<AppState>(context, listen: false);
    var employeeNo = prefs.getString('employeeNo') ?? '';

    await appState.checkStatus(employeeNo, context);
    if (appState.isActive == false) {
      setState(() {
        isValidating = false;
      });
      return;
    }
    _prefs.then((SharedPreferences prefs) async {
      phoneNumber = prefs.getString('phoneNumber') ?? '';
      Map<String, dynamic> data = {'mobileNo': phoneNumber, 'mpin': mPin};
      String key = generateRandomKey();
      String base64iv = generateRandomIV();
      String result = aesGcmEncryptJson(jsonEncode(data), key, base64iv);
      String apiLink = dotenv.env['API_LINK']!;
      Map<String, dynamic> postData = {
        "encryptedData": result,
        "key": key,
        "base64IV": base64iv,
      };
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Charset': 'utf-8',
        "Accept": "application/json",
        "Authorization": 'Bearer ${appState.accessToken}'
      };
      try {
        final response = await dio.post('${apiLink}Cafe/validateMPIN',
            data: postData, options: Options(headers: headers));
        if (response.statusCode == 200) {
          if (response.data == 'MPIN is valid') {
            setState(() {
              isValidating = false;
            });
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } on DioException catch (e) {
        setState(() {
          isValidating = false;
        });
        if (e.response.toString() == 'Invalid MPIN') {
          setState(() {
            if (buttonCounter > 0) {
              buttonCounter--;
            }
          });
          if (buttonCounter == 0) {
            int currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
            prefs.setString(
                'storedTriesTimestamp', currentTimeStamp.toString());
            prefs.setBool('isLocked', true);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const LockedScreen(
                          timestamp: '10',
                        )),
                (_) => false);
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Invalid MPIN. Please try again!"),
              action: SnackBarAction(
                label: ' Cancel',
                onPressed: () {},
              )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Technical Error!"),
              action: SnackBarAction(
                label: ' Cancel',
                onPressed: () {},
              )));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Color.fromRGBO(112, 12, 121, 0.55),
                  Color.fromRGBO(63, 166, 235, 0.55)
                ],
              ),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
                    child: Center(
                      child: SizedBox(
                          width: 160,
                          height: 160,
                          child: Image.asset('assets/images/cafe_logo.jpg')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 25, 15, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 25, bottom: 0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                obscureText: passwordVisible,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(255, 112, 12, 121),
                                          width: 2.0),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                    ),
                                    prefixIconColor:
                                        MaterialStateColor.resolveWith(
                                            (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.focused)) {
                                        return const Color.fromARGB(
                                            255, 112, 12, 121);
                                      }
                                      return Colors.grey;
                                    }),
                                    suffixIcon: IconButton(
                                      icon: Icon(passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(
                                          () {
                                            passwordVisible = !passwordVisible;
                                          },
                                        );
                                      },
                                    ),
                                    suffixIconColor:
                                        const Color.fromARGB(255, 112, 12, 121),
                                    alignLabelWithHint: false,
                                    filled: true,
                                    border: const OutlineInputBorder(),
                                    labelText: 'Enter MPIN',
                                    labelStyle: TextStyle(
                                        color: isFocus
                                            ? const Color.fromARGB(
                                                255, 112, 12, 121)
                                            : Colors.grey),
                                    hintText: 'Enter secure 4-Digit MPIN'),
                                maxLength: 4,
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Please Enter MPIN';
                                  } else if (value.length < 4) {
                                    return 'Please enter 4-Digit MPIN';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                focusNode: focusNode,
                                onChanged: (val) =>
                                    {setState(() => mPin = val)},
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 65,
                            width: 360,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 21),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 112, 12, 121),
                                ),
                                onPressed: buttonCounter > 0
                                    ? () async {
                                        if (_formKey.currentState!.validate()) {
                                          await validateMpin();
                                        } else {}
                                      }
                                    : null,
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child:
                                  Text('Only $buttonCounter attempts left!')),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton(
                            onPressed: () {
                              _prefs.then((SharedPreferences prefs) {
                                prefs.setString('phoneNumber', '');
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/one', (route) => false);
                              });
                            },
                            child: const Text(
                              'Reset MPIN?',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 25, 95, 226)),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: ClipPath(
                    clipper: WaveClipperTwo(reverse: true),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/images/shop.png',
                        width: 250,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ))
                ]),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        '© SBI General Insurance Company Limited | All Rights Reserved.',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 45, 3, 49)),
                      ),
                    ),
                  ]),
            ),
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
  }
}
