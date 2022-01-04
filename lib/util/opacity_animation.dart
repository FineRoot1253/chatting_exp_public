import 'package:flutter/material.dart';

class OpacityAnimation extends StatefulWidget {
  final Widget showWidget;
  final bool repeat;
  final int duration;
  final double begin;

  OpacityAnimation(
      {required this.showWidget, this.repeat = true, this.duration = 500, this.begin = 0});

  @override
  _OpacityAnimationState createState() => _OpacityAnimationState();
}

class _OpacityAnimationState extends State<OpacityAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));
    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: Tween(begin: widget.begin, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.decelerate)),
        child: widget.showWidget);
  }
}