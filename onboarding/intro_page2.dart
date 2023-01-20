

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber[100],
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Lottie.asset('lib/images/page2.json',
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
                  Text('Learn online from your home',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Learn a lot of new skill with our interesting lessons by our courses and solve your confusion.',
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
