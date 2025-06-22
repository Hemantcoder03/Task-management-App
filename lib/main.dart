import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:todo_list/intro/Intro.dart';
import 'package:todo_list/notification/NotificationService.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:todo_list/splash/Splash.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'Utlity/Constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Constants.getTransparentBottomBar();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(statusBarColor: Color.fromARGB(255, 82, 71, 71)));

    Future.delayed(
      Duration.zero,
      () async {
        await NotificationService().initNotification();
        tz.initializeTimeZones();
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      },
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(  //common transparent status bar
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
      ),
      child: ShowCaseWidget(
        builder: (BuildContext context) {
          return Builder(
            builder: (context) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  fontFamily: 'Mont',
                  primaryColor: Colors.white,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent),
              home: const SafeArea(
                child: Scaffold(
                  body: Splash(),
                  // body: Home(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
