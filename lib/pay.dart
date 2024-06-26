import 'dart:math';
import 'package:animated_check/animated_check.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

class DoneScreen extends StatefulWidget {
  final String location;
  final String amount;
  const DoneScreen({super.key, this.location = '', this.amount = ''});
  @override
  State<StatefulWidget> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _textController;
  late Animation<double> _text;
  final player = AudioPlayer();

  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    play();

    currentTime = DateTime.now();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));

    _confettiController.play();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.forward();
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutCirc));
    _textController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward()
          ..addListener(() {
            if (_textController.isCompleted) {
              _textController.repeat();
            }
          });
    _text = Tween<double>(begin: 0, end: 1).animate(_textController)
      ..addListener(
        () {
          setState(() {});
        },
      );
    _textController.forward();
  }

  void play() async {
    await player.setUrl('./sound.mp3');
    player.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(112, 12, 121, 0.55),
                  Color.fromRGBO(63, 166, 235, 0.55),
                ],
              ),
            ),
            child: Center(
                child: SingleChildScrollView(
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 75, 20, 50),
                        padding: const EdgeInsets.fromLTRB(15, 50, 15, 50),
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
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShaderMask(
                                  child: const Text(
                                    'Payment Successful',
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  shaderCallback: (rect) {
                                    return LinearGradient(stops: [
                                      _text.value - 0.5,
                                      _text.value,
                                      _text.value + 0.5,
                                    ], colors: const [
                                      Color.fromRGBO(112, 12, 121, 0.8),
                                      Color.fromRGBO(63, 166, 235, 1),
                                      Color.fromRGBO(12, 32, 121, 0.8),
                                    ]).createShader(rect);
                                  }),
                              const SizedBox(
                                height: 41,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromRGBO(38, 173, 20, 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(42, 4, 49, 0.4),
                                        blurRadius: 5.0, // soften the shadow
                                        spreadRadius: 2.0, //extend the shadow
                                        offset: Offset(
                                          5.0, // Move to right 5  horizontally
                                          5.0, // Move to bottom 5 Vertically
                                        ),
                                      )
                                    ]),
                                child: AnimatedCheck(
                                  progress: _animation,
                                  size: 150,
                                  color: Colors.white,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: ConfettiWidget(
                                  confettiController: _confettiController,
                                  blastDirection: -pi / 2,
                                  blastDirectionality:
                                      BlastDirectionality.explosive,
                                  emissionFrequency:
                                      0.003, // how often it should emit
                                  numberOfParticles:
                                      50, // number of particles to emit
                                  gravity: 0.03, // gravity - or fall speed
                                  shouldLoop: true,
                                  colors: const [
                                    Colors.green,
                                    Colors.blue,
                                    Colors.pink
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '₹ ',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(112, 12, 121, 1),
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.amount,
                                      style: const TextStyle(
                                          color:
                                              Color.fromRGBO(112, 12, 121, 1),
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ]),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Location: ',
                                      style: TextStyle(
                                        color: Color.fromRGBO(112, 12, 121, 1),
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      widget.location,
                                      style: const TextStyle(
                                        color: Color.fromRGBO(112, 12, 121, 1),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ]),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                DateFormat.yMMMMd()
                                    .add_jms()
                                    .format(currentTime)
                                    .toString(),
                                style: const TextStyle(
                                  color: Color.fromRGBO(112, 12, 121, 1),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(112, 12, 121, 1),
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 10, 40, 10)),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/home', (Route<dynamic> route) => false);
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ]))))));
  }
}
