

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.limeAccent[100],
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Lottie.asset('lib/images/page3.json',
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
                  Text('Update your future',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Technology is best when it brings people together',
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
