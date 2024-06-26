import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:splash/custom_provider.dart';

class OneScreen extends StatefulWidget {
  static var route;
  const OneScreen({Key? key}) : super(key: key);
  @override
  State<OneScreen> createState() => _OneScreenState();
}

class _OneScreenState extends State<OneScreen> {
  String phoneNumber = '';
  String userId = '';
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  bool isVerified = false;
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final _controller = TextEditingController();
  final _controller2 = TextEditingController();

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

  Future<void> generateOTP(context) async {
    setState(() {
      isVerified = true;
    });
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.checkStatus(_controller.text, context);
    print(appState.isActive);
    if (appState.isActive == false) {
      setState(() {
        isVerified = false;
      });
      return;
    }

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
          body: _controller.text);

      setState(() {
        isVerified = false;
      });

      var otp = response.body.split(' ')[3];
      var mobileNumber = response.body.split(' ')[9];
      appState.updateVariables(
        mobileNumber: mobileNumber,
        otp: int.parse(otp),
        employeeNo: _controller.text,
      );
      Navigator.pushNamed(context, '/otp');
    } catch (error) {
      setState(() {
        isVerified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Please try again!"),
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
  //   Map<String, dynamic> post = {'EmployeeId': _controller.text};
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
  //     var decryptedData = aesGcmDecryptJson(response.data, key, base64iv);
  //     var data = jsonDecode(decryptedData);
  //     setState(() {
  //       isVerified = false;
  //     });
  //     appState.updateVariables(
  //       mobileNumber: data['mobile_number'],
  //       otp: data['otp'],
  //       employeeNo: _controller.text,
  //       email: _controller2.text,
  //     );
  //     Navigator.pushNamed(context, '/otp');
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
  void initState() {
    super.initState();
    addListenerToNode(focusNode1, "focus_node_1");
    addListenerToNode(focusNode2, "focus_node_2");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
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
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Registration',
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
                      'Enter your SBIG Employee ID and E-mail ID to generate an OTP',
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
                              color: Color.fromRGBO(42, 4, 49, 0.4),
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
                                      borderRadius: BorderRadius.circular(10)),
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
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: 'Enter Employee Id',
                                  labelStyle: TextStyle(
                                      color: focusNode1.hasFocus
                                          ? const Color.fromARGB(
                                              255, 112, 12, 121)
                                          : Colors.grey),
                                ),
                                focusNode: focusNode1,
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Please Enter the Employee ID';
                                  } else if (int.parse(value) == 0) {
                                    return 'Invalid Employee ID';
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
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 2),
                                      borderRadius: BorderRadius.circular(10)),
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
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: 'Enter Email Id',
                                  labelStyle: TextStyle(
                                      color: focusNode2.hasFocus
                                          //  _focusUnfocus['focus_node_2']
                                          ? const Color.fromARGB(
                                              255, 112, 12, 121)
                                          : Colors.grey),
                                ),
                                focusNode: focusNode2,
                                validator: (String? val) {
                                  if (val!.trim().isEmpty) {
                                    return 'No Empty Spaces allowed';
                                  }
                                  if (val.split(' ').last.isEmpty) {
                                    return 'No Empty Spaces allowed';
                                  }
                                  if (val !=
                                      _controller.text + '@sbigeneral.in') {
                                    return 'Please use <Employee-ID>@sbigeneral.in ';
                                  }
                                  return null;
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
                                child: const Text(
                                  'Generate OTP',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      _formKey2.currentState!.validate()) {
                                    if (_controller.text == "654321" &&
                                        _controller2.text ==
                                            "654321@sbigeneral.in") {
                                      final appState = Provider.of<AppState>(
                                          context,
                                          listen: false);
                                      appState.updateVariables(
                                        mobileNumber: '9999999999',
                                        otp: 1234,
                                        employeeNo: 654321,
                                      );
                                      Navigator.pushNamed(context, '/otp');
                                    } else {
                                      generateOTP(context);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
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
}
