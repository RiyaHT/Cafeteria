import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool isOnline = true;

  @override
  void initState() {
    super.initState();

    Connectivity().onConnectivityChanged.listen((event) {
      setState(() {
        isOnline = event != ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isOnline ? widget.child : OfflineScreen();
  }
}

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
          Icon(
            Icons.signal_wifi_statusbar_connected_no_internet_4_outlined,
            color: Color.fromARGB(255, 47, 6, 51),
            size: 50,
          ),
          SizedBox(
            height: 10,
          ),
          Text('No Internet Connection',
              maxLines: 2,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 47, 6, 51))),
        ])));
  }
}
