import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:todo_list/Utlity/Constants.dart';
import 'package:todo_list/db/DBHelper.dart';
import 'package:todo_list/dialogs/NewTaskDialog.dart';

import '../Utlity/Strings.dart';
import '../model/TaskModel.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  DBHelper dbHelper = DBHelper.instance;
  String selectedCategory = 'All';
  List<Task> tasks = List.empty(growable: true);
  SharedPreferences? prefs;
  List<Map<String, dynamic>> uniqueDatesList = List.empty(growable: true);
  List<String> categoryList = List.empty(growable: true);
  final TextEditingController _newCategoryText = TextEditingController();

  DateFormat yMMMd = DateFormat.yMMMd();

  //keys for showcase
  final GlobalKey _addTaskBtn = GlobalKey();
  final GlobalKey _addCategoryBtn = GlobalKey();
  final GlobalKey _demoTask = GlobalKey();

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    Future.delayed(
      Duration.zero,
      () async {
        //get and set default category type
        prefs = await Constants.getSharedPrefs();
        if (prefs != null &&
            (prefs!.getStringList("categoryList") == null ||
                prefs!.getStringList("categoryList")!.isEmpty)) {
          prefs!.setStringList("categoryList", Constants.categoryList);
        }

        //if list is not empty or default list is set
        if (prefs != null) {
          categoryList = prefs!.getStringList("categoryList")!;
        }

        uniqueDatesList = await dbHelper.getDistinctDate();

        print("uniqueDatesList $uniqueDatesList");

        Constants.getLoadingDialog(context);
        if (selectedCategory == "All") {
          tasks = await dbHelper.getAllTasks();
        } else {
          tasks = await dbHelper.getTasksByCategory(selectedCategory);
        }
        //sort by datetime
        tasks.sort(
          (a, b) => ("${a.insertedDate} ${a.time}")
              .compareTo("${b.insertedDate} ${b.time}"),
        );

        Constants.hideLoader(context);

        bool? showAddNewTask = prefs!.getBool('showAddNewTask');
        bool? showAddCategory = prefs!.getBool('showAddCategory');

        if(showAddNewTask != null){
          bool? setDemoTask = prefs!.getBool('setDemoTask');
          List<Task>? taskList = await dbHelper.getAllTasks();
          if (setDemoTask == null && taskList.isEmpty) {
            //insert demo data to show delete task
            await dbHelper.createTask(
              Task(
                1,
                "Task",
                "Personal",
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                DateFormat('hh:mm a').format(DateTime.now()),
                0,
                0,
              ),
            );
            prefs!.setBool("setDemoTask", true);
          }
        }

        //show demo for first time
        if (showAddCategory == null) {
          //delay to load all categories
          if(showAddNewTask != null){
            Future.delayed(
              const Duration(seconds: 1),
              () {
                setState(() {});
                WidgetsBinding.instance.addPostFrameCallback(
                      (_) => ShowCaseWidget.of(context).startShowCase(
                    [
                      _addCategoryBtn,
                      _demoTask,
                    ],
                  ),
                );
              },
            );
          }
          else{
            WidgetsBinding.instance.addPostFrameCallback(
                  (_) => ShowCaseWidget.of(context).startShowCase(
                [
                  showAddNewTask == null ? _addTaskBtn : _addCategoryBtn,
                  showAddNewTask == null ? _addTaskBtn : _demoTask,
                ],
              ),
            );
          }

        }

        if (showAddNewTask == null) {
          prefs!.setBool("showAddNewTask", true);
        } else if (showAddCategory == null) {
          prefs!.setBool("showAddCategory", true);
        }

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 20, 5),
            child: Row(
              children: [
                Column(
                  children: [
                    const Text(
                      "Today's Tasks",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        DateFormat('dd MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Showcase(
                  key: _addTaskBtn,
                  targetShapeBorder: const CircleBorder(),
                  title: "Add new task",
                  description: 'Tap to add a new task and stay organized',
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
                  tooltipBorderRadius: Constants.borderRadius10,
                  tooltipPadding: Constants.padding10,
                  tooltipActionConfig: const TooltipActionConfig(
                    alignment: MainAxisAlignment.end,
                  ),
                  tooltipActions: [
                    TooltipActionButton(
                      type: TooltipDefaultActionType.skip,
                      borderRadius: Constants.borderRadius10,
                      textStyle: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    TooltipActionButton(
                      type: TooltipDefaultActionType.next,
                      borderRadius: Constants.borderRadius10,
                      backgroundColor: Colors.lightBlue,
                      textStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      onTap: () async {
                        ShowCaseWidget.of(context).dismiss();
                        final result = await showNewTaskDialog();
                        if (result != null && result == "added") {
                          ShowCaseWidget.of(context).next();
                        }
                      },
                    ),
                  ],
                  onTargetClick: () {
                    showNewTaskDialog();
                  },
                  disposeOnTap: true,
                  disableBarrierInteraction: true,
                  child: InkWell(
                    onTap: () {
                      showNewTaskDialog();
                    },
                    child: getAddTaskWidget(),
                  ),
                ),
              ],
            ),
          ),
          getCategoryList(),
          Constants.sizeBoxH10,
          tasks.isEmpty ? Constants.getNoDataFound() : getTaskListByDate(),
        ],
      ),
    );
  }

  getCategoryList() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              alignment: AlignmentDirectional.centerStart,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () async {
                        selectedCategory = categoryList[index];
                        setState(() {});
                        _init();
                      },
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                              bottom: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: Constants.borderRadius10,
                              color: selectedCategory == categoryList[index]
                                  ? Colors.lightBlue
                                  : Colors.white,
                            ),
                            child: Text(
                              categoryList[index],
                              style: TextStyle(
                                color: selectedCategory == categoryList[index]
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: categoryList[index] == "All",
                            child: Container(
                              width: 1.5,
                              margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: Constants.borderRadius20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      categoryList[index] == "All"
                          ? const SizedBox()
                          : Constants.sizeBoxW5,
                  itemCount: categoryList.length),
            ),
            InkWell(
              onTap: () {
                showAddDialog();
              },
              child: Showcase(
                key: _addCategoryBtn,
                title: "Add category",
                description:
                    'Tap to create a new category for better organization',
                tooltipPadding: Constants.padding10,
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
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 2,
                        right: 10,
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: Constants.borderRadius10,
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add),
                          Constants.sizeBoxW5,
                          const Text("Add"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getTaskListByDate() {
    //get date and previous date tasks //used to compare dates and avoid repetition of "overdue"
    // String day = getDaysOrDate(date);
    // String previousDay = getDaysOrDate(previousDate);

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return getTaskList(
              uniqueDatesList[index]['insertedDate'],
              index != 0
                  ? uniqueDatesList[index - 1]['insertedDate']
                  : "start",index);
        },
        itemCount: uniqueDatesList.length,
      ),
    );
  }

  getTaskList(String date, String previousDate, int taskListIndex) {
    //get separate list for tasks by date
    Iterable<Task> listByDate = tasks.where(
      (element) {
        if (element.insertedDate == date) {
          return true;
        }
        return false;
      },
    );

    //get date and previous date tasks //used to compare dates and avoid repetition of "overdue"
    String day = getDaysOrDate(date);
    String previousDay = previousDate != "start"
        ? getDaysOrDate(previousDate)
        : "start"; //start used to indicate it is at 0 index

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: listByDate.isNotEmpty && day != previousDay,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: getDaysOrDate(date) == "Overdue"
                    ? Colors.red
                    : Colors.black,
              ),
            ),
          ),
        ),
        Visibility(
          visible: day == previousDay,
          child: Constants.sizeBoxH5,
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return getTaskItem(
                listByDate.elementAt(index), index, listByDate.last, date,taskListIndex);
          },
          separatorBuilder: (context, index) => Constants.sizeBoxH5,
          itemCount: listByDate.length,
        ),
      ],
    );
  }

  getTaskItem(Task task, int index, Task lastTask, String date, int tasKListIndex) {
    return Showcase(
      key: tasKListIndex == 0 && index == 0 ? _demoTask : GlobalKey(),
      // show 'showcase' only for first index
      title: "Swipe to Delete",
      description: 'Swipe left or right to remove the item from the list',
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
      child: InkWell(
        onTap: () async {
          String? isUpdated = await updateTask(context, task.id!, task.status);
          if (isUpdated != null && isUpdated == "updated") {
            Constants.showSnackBar(context, "Task Updated Successfully");
            _init();
          } else {
            Constants.showSnackBar(context, Strings.somethingWentWrong);
          }
        },
        child: Dismissible(
          key: UniqueKey(),
          background: Container(
            color: Colors.red,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),
          onDismissed: (direction) async {
            int isDeleted = await dbHelper.deleteTask(task.id!);
            if (isDeleted > 0) {
              print("task $isDeleted");
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              undoSnackBar(task, index);
              _init();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            margin: uniqueDatesList[uniqueDatesList.length - 1]['date'] == date
                ? const EdgeInsets.fromLTRB(10, 0, 10, 10)
                : task.id == lastTask.id
                    ? const EdgeInsets.fromLTRB(10, 0, 10, 10)
                    : const EdgeInsets.symmetric(horizontal: 10),
            // margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: Constants.borderRadius10,
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      task.title.length > 20
                          ? "${task.title.substring(0, 20)}..."
                          : task.title,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        decoration: task.status == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 1.4,
                      child: Checkbox(
                        value: task.status == 1,
                        fillColor: const WidgetStatePropertyAll(Colors.blue),
                        shape: const CircleBorder(),
                        side: const BorderSide(
                          width: 0,
                          color: Colors.white,
                        ),
                        splashRadius: 20,
                        onChanged: (value) async {
                          task.status = value! ? 1 : 0;
                          setState(() {});
                          int isUpdated =
                              await dbHelper.updateTask(task.id!, task.status);
                          if (isUpdated > 0) {
                            _init();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Text(
                  task.type,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Divider(
                  color: Colors.grey[200],
                ),
                Row(
                  children: [
                    Text(
                      yMMMd.format(
                          DateFormat("dd/MM/yyyy").parse(task.insertedDate)),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Constants.sizeBoxW10,
                    Text(
                      task.time,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  updateTask(BuildContext context, int id, int status) async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity,
          child: NewTaskDialog("update", id, status),
        ),
      ),
    );
    return result;
  }

  undoSnackBar(Task task, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("This task is deleted."),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.white70,
          onPressed: () {
            if (index < 0) {
              tasks.add(task);
            } else {
              tasks.insert(index, task);
            }
            dbHelper.createTask(task);
            if (context.mounted) {
              _init();
            }
          },
        ),
      ),
    );
  }

  String getDaysOrDate(String date) {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    // DateFormat dateFormat = DateFormat.yMMMd();
    if (date == dateFormat.format(DateTime.now())) {
      return "Today";
    } else if (date ==
        dateFormat.format(
          DateTime.now().add(
            const Duration(hours: 24),
          ),
        )) {
      return "Tomorrow";
    } else if (dateFormat.parse(date).isBefore(DateTime.now())) {
      return "Overdue";
    }

    DateTime newDate = DateFormat("dd/MM/yyyy").parse(date);
    return yMMMd.format(newDate);
  }

  Future<void> showAddDialog() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create New Category",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              Constants.sizeBoxH10,
              TextField(
                controller: _newCategoryText,
                decoration: InputDecoration(
                  hintText: "Enter Category Name",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: Constants.borderRadius10,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: Constants.borderRadius10,
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              Constants.sizeBoxH10,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll(
                      Colors.blue,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: Constants.borderRadius10,
                        side: BorderSide.none,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if (_newCategoryText.text.isNotEmpty) {
                      categoryList.add(_newCategoryText.text);
                      await prefs!.setStringList("categoryList", categoryList);
                      Navigator.pop(context);
                      _init();
                    } else {
                      Constants.showSnackBar(
                          context, "Please enter category name");
                    }
                  },
                  child: const Text("Create"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getAddTaskWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      padding: Constants.padding10,
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Colors.blue[900],
          ),
          Constants.sizeBoxW5,
          Text(
            "Add Task",
            style: TextStyle(
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> showNewTaskDialog() async {
    final result = await Constants.getNewTask(context);
    if (result == "added") {
      _init();
    }
    return result;
  }
}
