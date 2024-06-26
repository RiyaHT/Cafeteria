import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'custom_provider.dart';
import 'dio_singleton.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Dio dio = DioSingleton.dio;
  String phoneNumber = '';
  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    _prefs.then((SharedPreferences prefs) {
      setState(() {
        phoneNumber = prefs.getString('phoneNumber') ?? '';
      });
    });
    createUser();
  }

  Future<void> createUser() async {
    setState(() {
      isLoading = true;
    });
    _prefs.then((SharedPreferences prefs) async {
      String apiLink = dotenv.env['API_LINK']!;
      final appState = Provider.of<AppState>(context, listen: false);
      Map<String, dynamic> postData = {
        "user_mobile": prefs.getString('phoneNumber') ?? '',
      };
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/json",
        "Authorization": 'Bearer ${appState.accessToken}'
      };
      try {
        final response = await dio.post('${apiLink}Cafe/getUserDetailsByMobile',
            data: postData, options: Options(headers: headers));
        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
            user = User.fromJson(jsonDecode(response.data));
          });
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        appState.showTechnicalError(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white12,
                  ],
                ),
              ),
            ),
            shape: const Border(
                bottom: BorderSide(
                    color: Color.fromRGBO(112, 12, 121, 1), width: 2)),
            title: const Text(
              "Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(112, 12, 121, 1),
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              color: const Color.fromRGBO(112, 12, 121, 1),
            )),
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
            ),
            child: SingleChildScrollView(
                child: Column(children: [
              Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const CircleAvatar(
                      radius: 73,
                      backgroundColor: Color(0xFF700C79),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_2_outlined,
                          size: 100,
                          color: Color(0xFF700C79),
                        ),
                      ))),
              Container(
                  // width: 400,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(42, 4, 49, 0.4),
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 2.0, //extend the shadow
                        offset: Offset(
                          5.0, // Move to right 5  horizontally
                          5.0, // Move to bottom 5 Vertically
                        ),
                      ),
                    ],
                  ),
                  child: Column(children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(children: [
                      const Text('    '),
                      const CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Color.fromRGBO(112, 12, 121, 1),
                        ),
                      ),
                      const Text(
                        '  NAME       : ',
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(112, 12, 121, 1)),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${user?.userName} ',
                                softWrap: false,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(112, 12, 121, 1)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(children: [
                      const Text('    '),
                      const CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.card_membership,
                          color: Color(0xFF700C79),
                        ),
                      ),
                      Row(children: [
                        const Text(
                          '  EMP ID     : ',
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(112, 12, 121, 1)),
                        ),
                        Text(
                          '${user?.userEmployeeno} ',
                          softWrap: false,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(112, 12, 121, 1)),
                        ),
                      ]),
                    ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(children: [
                      const Text('    '),
                      const CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.email,
                          color: Color(0xFF700C79),
                        ),
                      ),
                      const Text(
                        '  E-MAIL     : ',
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(112, 12, 121, 1)),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${user?.userEmail} ',
                                softWrap: false,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(112, 12, 121, 1)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      const Text('    '),
                      const CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.phone,
                          color: Color.fromRGBO(112, 12, 121, 1),
                        ),
                      ),

                      const Text(
                        '  CONTACT : ',
                        softWrap: false,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(112, 12, 121, 1)),
                      ),

                      Text(
                        phoneNumber,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(112, 12, 121, 1)),
                      ),
                      // )
                    ]),
                    const SizedBox(
                      height: 20,
                    ),
                  ])),
              const SizedBox(
                height: 50,
              ),
            ])),
          ),
          isLoading
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

class User {
  User(this.userName, this.userEmployeeno, this.userEmail);
  final String userEmployeeno;
  final String userName;
  final String userEmail;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['userName'], json['userEmployeeno'], json['userEmail']);
  }
}
