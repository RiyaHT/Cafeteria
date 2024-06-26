import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash/connectivityWrapper.dart';
import 'package:splash/custom_provider.dart';
import 'package:splash/home.dart';
import 'package:splash/otp.dart';
import 'package:splash/pay.dart';
import 'package:splash/payment.dart';
import 'package:splash/profile.dart';
import 'package:provider/provider.dart';
import 'package:splash/scanner.dart';
import 'package:splash/splash.dart';
import 'package:splash/step1.dart';
import 'package:splash/step2.dart';
import 'history.dart';
import 'lock.dart';
import 'login.dart';
import 'mpin.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  setPathUrlStrategy();
  await dotenv.load();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.errorDetails = ''});

  final String errorDetails;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Widget homeWidget = const SplashScreen();

  @override
  void initState() {
    super.initState();

    _prefs.then((SharedPreferences prefs) {
      int currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
      var storedTimeStamp = prefs.getString('storedTriesTimestamp') ?? '';
      final differenceInMinutes =
          (currentTimeStamp - int.parse(storedTimeStamp)) ~/ 60000;
      if (differenceInMinutes >= 10) {
        prefs.setBool('isLocked', false);
      } else {
        setState(() {
          homeWidget =
              LockedScreen(timestamp: (10 - differenceInMinutes).toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.createToken();
    Timer.periodic(const Duration(seconds: 240), (timer) async {
      await appState.createToken();
    });

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SBIG-Cafe',
        navigatorKey: navigatorKey,
        // home: widget.errorDetails.isEmpty
        //     ? const SplashScreen()
        //     : const RepairScreen(),
        home: homeWidget,
        onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => ConnectivityWrapper(
                    child: FutureBuilder<Widget>(
                  future: _buildWidgets(settings),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return snapshot.data ?? Container();
                    }
                  },
                ))));
  }

  Future<Widget> _buildWidgets(RouteSettings setting) async {
    // final args = setting.arguments as Map<String, dynamic>;

    switch (setting.name) {
      case '/one':
        return const OneScreen();
      case '/two':
        return TwoScreen();
      case '/otp':
        return const OtpScreen();
      case '/mpin':
        return const PinScreen();
      case '/scanner':
        return const QRScanScreen();
      case '/payment':
        return const PaymentScreen(
          location: '',
        );
      case '/done':
        return const DoneScreen();
      case '/history':
        return const HistoryScreen();
      case '/home':
        return const HomeScreen();
      case '/profile':
        return const ProfileScreen();
      case '/login':
        return const LoginScreen();
      default:
        return const SplashScreen();
    }
  }
}
