import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'package:http/http.dart' as https;
import 'dart:convert';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:splash/crypto_utils.dart';

import 'custom_provider.dart';
import 'dio_singleton.dart';
// import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class TwoScreen extends StatefulWidget {
  TwoScreen({this.mobileNumber = '', this.employeeNo = '', super.key});
  var mobileNumber;
  var employeeNo;
  @override
  State<TwoScreen> createState() => _TwoScreenState();
}

class _TwoScreenState extends State<TwoScreen> {
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String phoneNumber = '';
  String userId = '';
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  int buttonCounter = 3;
  bool isValidating = false;
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  Dio dio = DioSingleton.dio;
  final _controller = TextEditingController();
  final _controller2 = TextEditingController();

  bool passwordVisible = true;

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  final Map<dynamic, dynamic> _focusUnfocus = {
    "focus_node_1": false,
    "focus_node_2": false,
  };

  addListenerToNode(FocusNode focusNode, String key) {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _focusUnfocus[key] = true;
      } else {
        _focusUnfocus[key] = false;
      }
      setState(() {});
    });
  }

  // validateUser(context) async {
  //   setState(() {
  //     isValidating = true;
  //   });

  //   final appState = Provider.of<AppState>(context, listen: false);
  //   try {
  //     final response = await https.post(
  //         Uri.parse('https://cafeuat.sbigeneral.in/Cafe/verifyLDAP'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //           "Accept": "application/json",
  //           "Authorization": 'Bearer ${appState.accessToken}'
  //         },
  //         body: jsonEncode(
  //             {"employeeId": _controller.text, "password": _controller2.text}));
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         isValidating = false;
  //       });
  //       Navigator.pushReplacementNamed(
  //         context,
  //         '/mpin',
  //       );
  //     }
  //   } catch (error) {
  //     setState(() {
  //       isValidating = false;
  //     });
  //     setState(() {
  //       if (buttonCounter > 0) {
  //         buttonCounter--;
  //       }
  //     });
  //     if (buttonCounter == 0) {
  //       Navigator.pushReplacementNamed(context, '/one');
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: const Text("Wrong Credentials!"),
  //         action: SnackBarAction(
  //           label: ' Cancel',
  //           onPressed: () {},
  //         )));
  //   }
  // }

  validateUser() async {
    setState(() {
      isValidating = true;
    });
    Map<String, dynamic> data = {
      "employeeId": _controller.text,
      "password": _controller2.text
    };
    String key = generateRandomKey();
    String base64iv = generateRandomIV();
    String result = aesGcmEncryptJson(jsonEncode(data), key, base64iv);
    String apiLink = dotenv.env['API_LINK']!;
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, dynamic> postData = {
      "encryptedData": result,
      "key": key,
      "base64IV": base64iv,
    };
    // final response = await https.post(
    //   Uri.parse(
    //       '${apiLink}Cafe/verifyLDAP?EmployeeId=${_controller.text}&Password=${_controller2.text}'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     "Accept": "application/json",
    //     "X-IBM-Client-Id": "b45c81dd7930c8d98d103a26254d09ad",
    //     "X-IBM-Client-Secret": "a0410430190ebfd8ac4cabc1ea6d8fc9",
    //     "Authorization": 'Bearer ${appState.accessToken}'
    //   },
    // );

    Map<String, dynamic> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Charset': 'utf-8',
      "Accept": "application/json",
      "Authorization": 'Bearer ${appState.accessToken}',
    };
    // Timer(
    //     const Duration(seconds: 5),
    //     () => setState(() {
    //           isValidating = false;
    //           Navigator.pushReplacementNamed(
    //             context,
    //             '/mpin',
    //           );
    //         }));
    try {
      final response = await dio.post('${apiLink}Cafe/verifyLDAP',
          data: postData,
          options: Options(
            headers: headers,
            // sendTimeout: Duration(seconds: 10),
            // receiveTimeout: Duration(seconds: 10)
          ));

      if (response.data.toString() == "true") {
        setState(() {
          isValidating = false;
        });
        Navigator.pushReplacementNamed(
          context,
          '/mpin',
        );
      }
    } catch (error) {
      setState(() {
        isValidating = false;
      });
      setState(() {
        if (buttonCounter > 0) {
          buttonCounter--;
        }
      });
      if (buttonCounter == 0) {
        Navigator.pushReplacementNamed(context, '/one');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Wrong Credentials!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));

      // setState(() {
      //   isValidating = false;
      // });
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: const Text("Please try again!"),
      //     action: SnackBarAction(
      //       label: ' Cancel',
      //       onPressed: () {},
      //     )));
      // if (e.type == DioExceptionType.sendTimeout ||
      //     e.type == DioExceptionType.receiveTimeout) {
      //   setState(() {
      //     isValidating = false;
      //   });
      //   Navigator.pushReplacementNamed(
      //     context,
      //     '/mpin',
      //   );
      // }
    }
  }

  @override
  void initState() {
    super.initState();
    addListenerToNode(focusNode1, "focus_node_1");
    addListenerToNode(focusNode2, "focus_node_2");
    // _prefs.then((SharedPreferences prefs) {
    //   phoneNumber = prefs.getString('phoneNumber') ?? '';
    // });
  }

  // storeNumber() {

  //   _prefs.then((SharedPreferences pref) => {
  //         pref.setString('phoneNumber', phoneNumber),
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    // final arguments = (ModalRoute.of(context)!.settings.arguments ??
    //     <String, dynamic>{}) as Map;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: const Color.fromRGBO(112, 12, 121, 0.55),
        //   automaticallyImplyLeading: false,
        // ),
        body: Stack(children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(112, 12, 121, 0.55),
                  Color.fromRGBO(63, 166, 235, 0.55)
                ],
              ),
              //
            ),
            child: Center(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                            'assets/images/sign.jpg',
                          ),
                        ),
                      ),
                    ),
                    //
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Registration : Step 2',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 35.0, right: 35.0, top: 10),
                    child: Text(
                      'Enter your  SBIG Employee ID and Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                              color:
                                  //  Color.fromRGBO(231, 181, 229, 0.9),
                                  Color.fromRGBO(42, 4, 49, 0.4),
                              blurRadius: 5.0, // soften the shadow
                              spreadRadius: 2.0, //extend the shadow
                              offset: Offset(
                                3.0, // Move to right 5  horizontally
                                3.0, // Move to bottom 5 Vertically
                              ),
                            ),
                          ]),
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 30, bottom: 20),
                              child: TextFormField(
                                controller: _controller,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                maxLength: 6,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 112, 12, 121),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.person,
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
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    labelText: 'Enter Employee Id',
                                    labelStyle: TextStyle(
                                        color: focusNode1.hasFocus
                                            ? const Color.fromARGB(
                                                255, 112, 12, 121)
                                            : Colors.grey),
                                    hintText: 'Enter valid Employee Id'),
                                focusNode: focusNode1,
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Please Enter the Employee ID';
                                  } else if (int.parse(value) == 0) {
                                    return 'Invalid Employee ID';
                                  } else if (value != appState.employeeNo) {
                                    return 'Enter valid Employee ID';
                                  }

                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                          ),
                          Form(
                            key: _formKey2,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: TextFormField(
                                controller: _controller2,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: passwordVisible,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 112, 12, 121),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.email,
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
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    labelText: 'Enter Password',
                                    labelStyle: TextStyle(
                                        color: focusNode2.hasFocus
                                            //  _focusUnfocus['focus_node_2']
                                            ? const Color.fromARGB(
                                                255, 112, 12, 121)
                                            : Colors.grey),
                                    hintText: 'Enter valid password'),
                                focusNode: focusNode2,
                                validator: (String? val) {
                                  if (val!.isEmpty) {
                                    return "Please enter your Password";
                                  } else {
                                    if (!RegExp(
                                            r"^(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
                                        .hasMatch(val)) {
                                      return "Invalid Password";
                                    } else {
                                      return null;
                                    }
                                  }
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 65,
                            width: 360,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 35,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 112, 12, 121),
                                  elevation: 10, // Elevation
                                  shadowColor: Colors.purple[300],
                                ),
                                onPressed: buttonCounter > 0
                                    ? () async {
                                        if (_formKey.currentState!.validate() &&
                                            _formKey2.currentState!
                                                .validate()) {
                                          validateUser();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: const Text(
                                                      "Wrong Credentials!"),
                                                  action: SnackBarAction(
                                                    label: ' Cancel',
                                                    onPressed: () {},
                                                  )));
                                        }
                                      }
                                    : null,
                                child: const Text(
                                  'Validate',
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
                            height: 35,
                          ),
                        ],
                      ),
                    ),
                  ),
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
  }
}
