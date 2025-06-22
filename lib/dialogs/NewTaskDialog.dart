import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:todo_list/Utlity/Constants.dart';
import 'package:todo_list/db/DBHelper.dart';

import '../Utlity/Strings.dart';
import '../model/TaskModel.dart';
import '../notification/NotificationService.dart';

class NewTaskDialog extends StatefulWidget {
  String addOrUpdate;
  int? id;
  int status;

  NewTaskDialog(this.addOrUpdate, this.id, this.status, {super.key});

  @override
  State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog>
    with TickerProviderStateMixin {
  String selectedWorkType = "Personal";
  int selectedRemainder = 0;
  String selectedDate = '';
  String selectedTime = '';
  bool isTextFieldExtended = false;
  DBHelper dbHelper = DBHelper.instance;
  TextEditingController taskText = TextEditingController();
  List<String> categoryList = List.empty(growable: true);

  //notification
  NotificationService notificationService = NotificationService();
  SharedPreferences? prefs = null;
  String notificationPrefsKey = "notification";

  //date format
  DateFormat yyyyMMDD = DateFormat("dd/MM/yyyy");

  //animation in button
  late final AnimationController _addBtnAnimation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  //introduction key
  GlobalKey enterTaskTextField = GlobalKey();
  GlobalKey selectTaskType = GlobalKey();
  GlobalKey selectLastDate = GlobalKey();
  GlobalKey selectLastTime = GlobalKey();
  GlobalKey selectRemainder = GlobalKey();
  GlobalKey addBtn = GlobalKey();

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () async {
        if (widget.addOrUpdate == 'update') {
          Task task = await dbHelper.getTask(widget.id!);
          taskText.text = task.title;
          selectedWorkType = task.type;
          selectedDate = task.insertedDate;
          selectedTime = task.time;

          //set selected remainder
          selectedRemainder = task.remainderTime;
        }

        await notificationService.initNotification();
        prefs = await Constants.getSharedPrefs();

        if (prefs != null) {
          categoryList = prefs!.getStringList("categoryList")!;
          //Add other then "All" option in category selection list
          categoryList.removeWhere(
            (element) => element == "All",
          );
        }

        bool? addNewTask = prefs!.getBool('addNewTaskDialog');

        //show demo for first time
        if (prefs != null && addNewTask == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => ShowCaseWidget.of(context).startShowCase(
              [
                enterTaskTextField,
                selectTaskType,
                selectLastDate,
                selectLastTime,
                selectRemainder,
                addBtn,
              ],
            ),
          );

          prefs!.setBool("addNewTaskDialog", true);
        }

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Constants.borderRadius20,
        ),
        padding: Constants.padding20,
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Add New Task",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Constants.sizeBoxH10,
            Showcase(
              key: enterTaskTextField,
              title: "Enter Task",
              description: "Type the task details here",
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              descTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              titleAlignment: Alignment.center,
              descriptionTextAlign: TextAlign.center,
              child: getExpandableTextField("Task", "Enter your task", taskText,
                  isTextFieldExtended ? 5 : 1),
            ),
            Constants.sizeBoxH10,
            Showcase(
              key: selectTaskType,
              title: "Task Type",
              description: "Choose the type of task from the dropdown",
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              descTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              titleAlignment: Alignment.center,
              descriptionTextAlign: TextAlign.center,
              child: Constants.getCommonDropDown(
                "Task Type",
                categoryList,
                selectedWorkType,
                (value) {
                  setState(() {
                    selectedWorkType = value;
                  });
                },
              ),
            ),
            Constants.sizeBoxH10,
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Last Date",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          // firstDate: DateTime.now()
                          //     .subtract(const Duration(days: 10)),
                          lastDate: DateTime(2050),
                        );

                        if (date != null) {
                          setState(() {
                            selectedDate = Constants.getFormattedDate(date);
                          });
                        }
                      },
                      child: Showcase(
                        key: selectLastDate,
                        title: "Due Date",
                        description: "Pick the deadline for the task",
                        titleTextStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        descTextStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        titleAlignment: Alignment.center,
                        descriptionTextAlign: TextAlign.center,
                        child: Container(
                          padding: Constants.padding10,
                          constraints: const BoxConstraints(minWidth: 120),
                          decoration: BoxDecoration(
                            borderRadius: Constants.borderRadius10,
                            color: Colors.grey[100],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                selectedDate.isNotEmpty ? selectedDate : "Date",
                              ),
                              Constants.sizeBoxW10,
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Last Time",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (time != null) {
                          setState(() {
                            selectedTime = time.format(context);
                          });
                        }
                      },
                      child: Showcase(
                        key: selectLastTime,
                        title: "Due Time",
                        description: "Set the time for task completion",
                        titleTextStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        descTextStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        titleAlignment: Alignment.center,
                        descriptionTextAlign: TextAlign.center,
                        child: Container(
                          padding: Constants.padding10,
                          decoration: BoxDecoration(
                            borderRadius: Constants.borderRadius10,
                            color: Colors.grey[100],
                          ),
                          constraints: const BoxConstraints(minWidth: 120),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                selectedTime.isNotEmpty ? selectedTime : "Time",
                              ),
                              Constants.sizeBoxW10,
                              const Icon(Icons.access_time_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            Constants.sizeBoxH10,
            Showcase(
              key: selectRemainder,
              title: "Remainder",
              description: "Set the time for task completion",
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              descTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              titleAlignment: Alignment.center,
              descriptionTextAlign: TextAlign.center,
              child: Constants.getCommonDropDown(
                "Remainder",
                Constants.remainderList,
                Constants.remainderList[selectedRemainder],
                (value) {
                  // selectedRemainder = value;
                  for (var i = 0; i < Constants.remainderList.length; i++) {
                    if (Constants.remainderList[i] == value) {
                      selectedRemainder = i;
                    }
                  }
                  setState(() {});
                },
              ),
            ),
            Constants.sizeBoxH20,
            Showcase(
              key: addBtn,
              title: "Add task",
              description: "Tap to save the task and add it to your list",
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              descTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              titleAlignment: Alignment.center,
              descriptionTextAlign: TextAlign.center,
              child: AnimatedBuilder(
                animation: _addBtnAnimation!,
                builder: (BuildContext context, Widget? child) {
                  final value =
                      _addBtnAnimation != null ? _addBtnAnimation!.value : 0;
                  final sinevalue = sin(5 * 2 * pi * value);
                  return Transform.translate(
                    offset: Offset(sinevalue * 10, 0),
                    child: InkWell(
                      onTap: () async {
                        print("selected Date $selectedDate");
                        print(
                            "date ${yyyyMMDD.parse(selectedDate).toString()}");

                        if (taskText.text.isEmpty) {
                          Constants.showToast(context, "Please Enter Task");
                        } else if (selectedDate.isEmpty) {
                          Constants.showToast(context, "Please select date");
                        } else if (selectedTime.isEmpty) {
                          Constants.showToast(context, "Please select time");
                        } else {
                          //check time
                          if (selectedRemainder != 0 &&
                              !notificationService.compareTime(
                                Constants.getFormattedDateTime(
                                    selectedDate, selectedTime),
                                Constants
                                    .remainderTimeList[selectedRemainder - 1],
                              )) {
                            _addBtnAnimation.forward(from: 0);
                            Constants.showToast(context,
                                "Please select a time at least 5 minutes later.");
                            selectedTime = '';
                            setState(() {});
                            return;
                          }

                          if (widget.addOrUpdate == "update") {
                            final isUpdated = await dbHelper.updateTaskDetails(
                              Task(
                                widget.id!,
                                taskText.text,
                                selectedWorkType,
                                selectedDate.toString(),
                                selectedTime,
                                selectedRemainder,
                                widget.status,
                              ),
                            );
                            if (isUpdated > 0) {
                              Constants.showToast(
                                  context, "Task Updated Successfully");
                            } else {
                              Constants.showToast(
                                  context, Strings.somethingWentWrong);
                            }
                            Navigator.pop(context, "updated");
                          } else {
                            final isInserted = await dbHelper.createTask(
                              Task(
                                null,
                                taskText.text,
                                selectedWorkType,
                                selectedDate.toString(),
                                selectedTime,
                                selectedRemainder,
                                0,
                              ),
                            );
                            if (isInserted > 0) {
                              print("isinserted $isInserted");
                              Constants.showSnackBar(
                                  context, "New Task Added Successfully");
                              if (selectedRemainder != 0) {
                                if (await requestNotificationPermission()) {
                                  // int id = 0;
                                  // if (prefs != null &&
                                  //     prefs!.containsKey(notificationPrefsKey)) {
                                  //   id = prefs!.getInt(notificationPrefsKey)!;
                                  //   prefs!.setInt(notificationPrefsKey, id + 1);
                                  // } else {
                                  //   prefs!.setInt(notificationPrefsKey, 0);
                                  // }
                                  // await notificationService
                                  //     .showScheduledNotification(
                                  //   Constants.getFormattedDateTime(
                                  //           selectedDate, selectedTime)
                                  //       .toString(),
                                  //   Constants
                                  //       .remainderTimeList[selectedRemainder - 1]
                                  //       .toString(),
                                  //   Constants.getFormattedDateTime(
                                  //       selectedDate, selectedTime),
                                  //   Constants1
                                  //       .remainderTimeList[selectedRemainder - 1],
                                  // );

                                  await notificationService
                                      .showScheduledNotification(
                                    isInserted,
                                    "Hey, don’t forget!",
                                    "Your task ${taskText.text.length > 17 ? "${taskText.text.toString().substring(0,18)}..." : taskText.text.toString()} is waiting. Tap to complete and boost productivity! 💪",
                                    // "Reminder: ${taskText.text.length > 25 ? "${taskText.text.toString().substring(0,26)}..." : taskText.text.toString()} needs your attention. Stay focused and get it done! ✅",
                                    Constants.getFormattedDateTime(
                                        selectedDate, selectedTime),
                                    Constants.remainderTimeList[
                                        selectedRemainder - 1],
                                  );
                                }
                              }
                            } else {
                              Constants.showToast(
                                  context, Strings.somethingWentWrong);
                            }
                            Navigator.pop(context, "added");
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: Constants.padding10,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: Constants.borderRadius10,
                        ),
                        child: Text(
                          widget.addOrUpdate == 'update' ? "UPDATE" : "ADD",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getExpandableTextField(String title, String hintText,
      TextEditingController controller, int minLines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        Constants.sizeBoxH5,
        TextField(
          minLines: minLines,
          maxLines: 5,
          controller: controller,
          decoration: InputDecoration(
            contentPadding: isTextFieldExtended
                ? const EdgeInsets.fromLTRB(10, 10, 10, 0)
                : const EdgeInsets.symmetric(horizontal: 10),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: Constants.borderRadius10,
            ),
            suffixIcon: IconButton(
                onPressed: () {
                  isTextFieldExtended = !isTextFieldExtended;
                  setState(() {});
                },
                icon: Icon(isTextFieldExtended
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded)),
            fillColor: Colors.grey[100],
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
