import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_list/db/DBHelper.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final String CHANNELID = "TodoList";
  final String CHANNELNAME = "Todo List";
  final String CHANNELDESC = "Remainder Notification";

  Future<void> initNotification() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@drawable/playstore_app_icon');
    var initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationBtnClicked,
      onDidReceiveBackgroundNotificationResponse: onNotificationBackgroundBtnClick,
    );
  }

  onNotificationBtnClicked(NotificationResponse response) async {
    if(response.actionId == "task_done"){
      final dbHelper = DBHelper.instance;
      final isUpdated = await dbHelper.updateTask(int.parse(response.payload ?? "0"), 1);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationBackgroundBtnClick(NotificationResponse response) async {
    if(response.actionId == "task_done"){
      final dbHelper = DBHelper.instance;
      final isUpdated = await dbHelper.updateTask(int.parse(response.payload ?? "0"), 1);
    }
  }

  Future<bool> showScheduledNotification(int lastInsertedTaskId,String notificationTitle,
      String notificationBody, DateTime time, int remainderTime) async {
    if (!compareTime(time, remainderTime)) {
      return false;
    }

    int uniqueId = Random().nextInt(100000);

    await notificationsPlugin.show(
      uniqueId,
      notificationTitle,
      notificationBody,
      getNotificationDetails(),
      payload: lastInsertedTaskId.toString()
    );

    // await notificationsPlugin.zonedSchedule(
    //   uniqueId,
    //   notificationTitle,
    //   notificationBody,
    //   // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
    //   getScheduleTime(time,remainderTime),
    //   getNotificationDetails(),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );
    return true;
  }

  //compare time to check present and future datetime
  bool compareTime(DateTime time, int remainderTime) {
    if (time.isBefore(
        DateTime.now().add(Duration(minutes: remainderTime /*+5*/)))) {
      return false;
    }
    return true;
  }

  tz.TZDateTime getScheduleTime(DateTime time, int minutes) {
    return tz.TZDateTime.from(time, tz.local)
        .subtract(Duration(minutes: minutes));
  }

  getNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        CHANNELID,
        CHANNELNAME,
        channelDescription: CHANNELDESC,
        color: Colors.blue,
        colorized: true,
        importance: Importance.high,
        priority: Priority.high,
        actions: [
          const AndroidNotificationAction(
            "task_done",
            "Task Done!",
            titleColor: Colors.blue,
            showsUserInterface: false,
          ),
        ],
      ),
    );
  }
}
