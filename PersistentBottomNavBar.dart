import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:scan_solve/screen/setting_screen.dart';
import 'package:scan_solve/services/app_lifecycle_reactor.dart';
import 'package:scan_solve/services/app_open_ad_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';
import 'learn/learn.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;

  String data = '';
  late StreamSubscription<FGBGType> subscription;
  List<Widget> _buildScreens() {
    return [
      const LearnScreen(),
      const CameraView(),
       SettingScreen(data: data,)
    ];
  }
  gdprAvailable() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    ConsentInformation.instance
        .requestConsentInfoUpdate(ConsentRequestParameters(), () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await preferences.setString('keyvalue', "1");
        data = (preferences.getString('keyvalue'))!;
      } else {
        await preferences.setString('keyvalue', "0");
        data = (preferences.getString('keyvalue'))!;
      }
    }, (error) {
      print("error");
    });
  }
  @override
  void initState() {
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
    gdprAvailable();
    setshared_preferences();
    super.initState();
  }

  final PersistentTabController _controller = PersistentTabController(initialIndex: 1);


  Future setshared_preferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('repeat', true);
  }


  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: 3.h,
          child: Image.asset(
            "images/bottomnavigation/learn_press.png",
          ),
        ),
        inactiveIcon: Transform.scale(
          scale: 2.6.h,
          child: Image.asset(
            "images/bottomnavigation/learn_unpress.png",
          ),
        ),
        activeColorPrimary: const Color(0xff70c484),
        activeColorSecondary: Colors.black,
        inactiveColorPrimary: CupertinoColors.black,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: 3.h,
          child: Image.asset(
            "images/bottomnavigation/scan_press.png",
          ),
        ),
        activeColorPrimary: const Color(0xff70c484),
        inactiveIcon: Transform.scale(
          scale: 2.6.h,
          child: Image.asset(
            "images/bottomnavigation/scan_unpress.png",
          ),
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Transform.scale(
          scale: 3.h,
          child: Image.asset(
            "images/bottomnavigation/setting_press.png",
          ),
        ),
        inactiveIcon: Transform.scale(
          scale: 2.6.h,
          child: Image.asset(
            "images/bottomnavigation/setting_unpress.png",
          ),
        ),
        //title: ("Home"),
        activeColorPrimary: const Color(0xff70c484),
      )
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        navBarHeight: 180.h,
        padding: const NavBarPadding.only(left: 2,right: 2),
        confineInSafeArea: true,
        backgroundColor: Colors.white, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: const ItemAnimationProperties( // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style1,
      ),
    );
  }
}
