//@dart=2.9

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../onboarding/Onboarding_mainPage.dart';

class SplashScreen extends StatefulWidget
{  @override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
{
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => OnboardindScreen()));
    },);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Lottie.asset('lib/images/splash.json',
                height: 300.0,
                repeat: true,
                reverse: true,
                animate: true
            ),
      ),
    );
  }}
