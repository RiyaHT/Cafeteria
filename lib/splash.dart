import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash/dio_singleton.dart';
import 'custom_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String phoneNumber = '';
  Dio dio = DioSingleton.dio;

  @override
  void initState() {
    super.initState();
  }

  checkStatus() {
    _prefs.then((SharedPreferences prefs) async {
      String apiLink = dotenv.env['API_LINK']!;
      final appState = Provider.of<AppState>(context, listen: false);
      Map<String, dynamic> postData = {
        "userEmployeeno": prefs.getString('employeeNo') ?? '',
      };
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/json",
        "Authorization": 'Bearer ${appState.accessToken}'
      };
      try {
        final response = await dio.post('${apiLink}Cafe/users/status',
            data: postData, options: Options(headers: headers));
        print(response.data);
        if (response.statusCode == 200) {
          // setState(() {
          //   isActive = true;
          // });
          appState.setIsActive();
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (error) {
        // print(error);
        Navigator.of(context).pushReplacementNamed('/one');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 3),
      () => _prefs.then((SharedPreferences prefs) {
        phoneNumber = prefs.getString('phoneNumber') ?? '';
        // employeeNo = prefs.getString('employeeNo') ?? '';
        // Navigator.pushReplacementNamed(context, '/mpin');
        if (phoneNumber == '') {
          Navigator.of(context).pushReplacementNamed('/one');
        } else {
          // if (isActive == true) {
          //   Navigator.of(context).pushReplacementNamed('/login');
          // } else {
          //   Navigator.of(context).pushReplacementNamed('/one');
          // }
          checkStatus();
        }
      }),
    );
    return Scaffold(
        body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(children: [
              Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 170,
                          height: 170,
                          child: Image.asset('assets/images/cafe_logo.jpg')),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: const Color.fromRGBO(112, 12, 121, 1),
                          size: 41,
                        ),
                      ),
                    ]),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
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
            ])));
  }
}
