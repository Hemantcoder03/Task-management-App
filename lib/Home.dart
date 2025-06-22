import 'package:flutter/material.dart';
import 'package:todo_list/Utlity/Constants.dart';
import 'package:todo_list/Notes/NotesList.dart';
import 'package:todo_list/Tasks/TaskList.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  color: Colors.white,
                ),
                child: TabBar(
                  indicatorColor: Colors.black,
                  splashBorderRadius: Constants.borderRadius20,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  tabs: const [
                    Tab(
                      child: Text(
                        "Tasks",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Quick Notes",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    TaskList(),
                    NotesList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
