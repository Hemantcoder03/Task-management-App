import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/Home.dart';
import 'package:todo_list/intro/Intro.dart';

import '../Utlity/Constants.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  //intro is presented or not
  bool intro = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () async {
        SharedPreferences prefs = await Constants.getSharedPrefs();
        intro = prefs.getBool('intro') ?? false;
        setState(() {});
      },
    );

    Future.delayed(
      const Duration(seconds: 2),
      () async {
        await navigateToMain();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/todo_app_icon.png',
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  Future<void> navigateToMain() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => !intro ? const Intro() : const Home(),
      ),
      (route) => false,
    );
  }
}
