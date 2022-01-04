import 'package:chatting_example/route/route_const.dart';
import 'package:chatting_example/util/opacity_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    
    await Future.delayed(const Duration(milliseconds: 500));

    Get.offAllNamed(RouteName.SignIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: OpacityAnimation(
              showWidget: Text(
                'Now loading...',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              duration: 800,
              begin: 0.3),
        ));
  }
}
