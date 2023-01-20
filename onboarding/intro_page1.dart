
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink[200],
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Lottie.asset('lib/images/page1.json',
                height: 400.0,
                repeat: true,
                reverse: true,
                animate: true
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Text('Welcome to the flutter knowledge',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('We will help you gain knowledge that will change your life',
                  textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
