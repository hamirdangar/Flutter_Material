
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../sign_in_up_page/Sign_In_Page.dart';
import 'intro_page1.dart';
import 'intro_page2.dart';
import 'intro_page3.dart';

class OnboardindScreen extends StatefulWidget
{
  @override
  State<OnboardindScreen> createState() => _OnboardindScreenState();
}

class _OnboardindScreenState extends State<OnboardindScreen> {
  PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index){
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          Container(
            alignment: Alignment(0,0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: (){

                    _controller.jumpToPage(2);
                  },
                  child: Text('Skip'),
                ),
                SmoothPageIndicator(
                    controller: _controller,
                    count: 3
                ),
                onLastPage ?
                InkWell(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text('Done')
                ):InkWell(
                    onTap: (){
                      _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                    },
                    child: Text('Next')
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
