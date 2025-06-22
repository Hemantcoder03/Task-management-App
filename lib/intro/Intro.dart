import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:todo_list/Home.dart';
import 'package:todo_list/Utlity/Constants.dart';
import 'package:todo_list/Utlity/Strings.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  int selectedPage = 0;
  CarouselSliderController sliderController = CarouselSliderController();
  PageController indicatorController = PageController(initialPage: 0);
  List<String> titleList = [
    'Keep your daily tasks in check!',
    'Make every moment count.',
    'Focus on what truly matters.',
  ];
  List<String> subTitleList = [
    'Quickly add, organize, and complete tasks with a clear to-do list to stay on top of your priorities.',
    'Set deadlines and reminders to plan your day effectively and stay on track.',
    'Focus on goals by breaking them into steps and celebrating your progress along the way.',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: [
              Constants.sizeBoxH10,
              const Text(
                Strings.appName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              getSlider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  titleList[selectedPage],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 50,),
                child: Text(subTitleList[selectedPage],textAlign: TextAlign.center,),
              ),
              Constants.sizeBoxH10,
              getDotIndicator(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: selectedPage != 2,
                      child: FilledButton(
                        onPressed: () async {
                          await navigateToMain();
                        },
                        style: const ButtonStyle(
                          backgroundColor: WidgetStateColor.transparent,
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Colors.black,
                        ),
                      ),
                      onPressed: () async {
                        sliderController.nextPage();
                        if (selectedPage != 2) {
                          ++selectedPage;
                          setState(() {});
                        } else {
                          await navigateToMain();
                        }
                      },
                      child: Text(
                        selectedPage == 2 ? "Get Started" : "Next",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getSlider() {
    return CarouselSlider(
      items: [
        Image.asset("assets/images/todo/check_list.jpg"),
        Image.asset("assets/images/todo/time_management.jpg"),
        Image.asset("assets/images/todo/achieve_goal.jpg"),
      ],
      carouselController: sliderController,
      options: CarouselOptions(
        height: 400,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        initialPage: 0,
        viewportFraction: 0.8,
      ),
    );
  }

  getDotIndicator() {
    return AnimatedSmoothIndicator(
      effect: const ExpandingDotsEffect(
        expansionFactor: 2,
        activeDotColor: Colors.black,
        dotHeight: 7,
        dotWidth: 7,
        spacing: 5,
        radius: 50,
      ),
      count: 3,
      activeIndex: selectedPage,
    );
  }

  Future<void> navigateToMain() async {
    SharedPreferences prefs = await Constants.getSharedPrefs();
    prefs.setBool('intro', true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Home(),
      ),
      (route) => false,
    );
  }
}
