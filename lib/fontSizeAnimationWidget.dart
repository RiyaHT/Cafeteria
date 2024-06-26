import 'package:flutter/material.dart';

class FontSizeAnimationWidget extends StatefulWidget {
  const FontSizeAnimationWidget({this.location = '', super.key});
  final String location;
  @override
  State<FontSizeAnimationWidget> createState() =>
      _FontSizeAnimationWidgetState();
}

class _FontSizeAnimationWidgetState extends State<FontSizeAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 12.0, end: 24.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        widget.location,
        style:
            TextStyle(fontSize: _animation.value, fontWeight: FontWeight.bold),
      ),
    );
  }
}
