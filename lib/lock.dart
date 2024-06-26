import 'dart:async';

import 'package:flutter/material.dart';

class LockedScreen extends StatefulWidget {
  final String timestamp;

  const LockedScreen({super.key, required this.timestamp});

  @override
  State<LockedScreen> createState() => _LockedScreenState();
}

class _LockedScreenState extends State<LockedScreen> {
  late int _minutes;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _minutes = int.parse(widget.timestamp);
    lockTimer();
  }

  lockTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        if (_minutes > 0) {
          _minutes--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
            child: Dialog(
              insetAnimationCurve: Curves.decelerate,
              insetAnimationDuration: const Duration(milliseconds: 200),
              shadowColor: const Color.fromARGB(255, 44, 2, 51),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(15.0),
                height: 250.0,
                width: 300.0,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: _minutes == 0
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                  Icon(
                                    Icons.lock_open,
                                    color: Color.fromARGB(255, 112, 12, 121),
                                    size: 55,
                                  ),
                                  Flexible(
                                    child: Text(
                                      ' Please Restart the App.',
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 6,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 112, 12, 121),
                                      ),
                                    ),
                                  ),
                                ])
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                  const Text(
                                    'Account is Locked',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 112, 12, 121),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.lock,
                                    color: Color.fromARGB(255, 112, 12, 121),
                                    size: 55,
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Your account is locked. \n Please try again after $_minutes minutes.',
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      maxLines: 6,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color:
                                            Color.fromARGB(255, 112, 12, 121),
                                      ),
                                    ),
                                  ),
                                ]),
                    ),
                  ],
                ),
              ),
            )));
  }
}
