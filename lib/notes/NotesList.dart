import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:todo_list/Utlity/Constants.dart';
import 'package:todo_list/db/DBHelper.dart';
import 'package:todo_list/dialogs/NewNoteDialog.dart';
import 'package:todo_list/dialogs/NoteDeleteDialog.dart';
import 'package:todo_list/model/NoteModel.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  List<String> notesImageArray = [
    'assets/images/notes/note1.png',
    'assets/images/notes/note2.png',
    'assets/images/notes/note3.png',
    'assets/images/notes/note4.png',
    'assets/images/notes/note5.png',
    'assets/images/notes/note6.png',
    'assets/images/notes/note7.png',
  ];
  List<Note> notesList = List.empty(growable: true);
  DBHelper dbHelper = DBHelper.instance;
  SharedPreferences? prefs;

  final GlobalKey _addNote = GlobalKey();
  final GlobalKey _demoNote = GlobalKey();
  final GlobalKey _demoNote2 = GlobalKey();

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {

    //get and set default category type
    prefs = await Constants.getSharedPrefs();

    if(prefs!.getBool('demoNote') == null){
      await dbHelper.createNote(Note(null, "Note", DateTime.now().toString(), 0));
      prefs!.setBool('demoNote', true);

      WidgetsBinding.instance.addPostFrameCallback(
            (_) => ShowCaseWidget.of(context).startShowCase(
          [
            _addNote,
            _demoNote
          ],
        ),
      );

      setState(() {});
    }

    notesList = await dbHelper.getAllNotes();



    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      // body: CustomScrollView(
      //   slivers: [
      //     SliverFillRemaining(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: <Widget>[
      //           Padding(
      //             padding: const EdgeInsets.only(
      //               top: 10,
      //               left: 10,
      //             ),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 const Text(
      //                   "Today's Notes",
      //                   style: TextStyle(
      //                     color: Colors.black,
      //                     fontWeight: FontWeight.bold,
      //                     fontSize: 18,
      //                   ),
      //                 ),
      //                 Text(
      //                   DateFormat('dd MMMM yyyy').format(DateTime.now()),
      //                   style: const TextStyle(
      //                     color: Colors.grey,
      //                     fontWeight: FontWeight.w500,
      //                     fontSize: 14,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           Expanded(
      //             child: notesList.isEmpty
      //                 ? getNoNoteFound()
      //                 : ListView.builder(
      //                     shrinkWrap: true,
      //                     physics: const NeverScrollableScrollPhysics(),
      //                     itemBuilder: (context, index) {
      //                       return getNoteItem(notesList[index], index);
      //                     },
      //                     itemCount: notesList.length,
      //                   ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Notes",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (notesList.isEmpty)
              getNoNoteFound()
            else
              //2 notes in single line
              // GridView.extent(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   maxCrossAxisExtent: 250,
              //   children: List.generate(notesList.length, (index) {
              //     return getNoteItem(notesList[index], index);
              //   },),
              // ),

              //1 note in single line
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return getNoteItem(notesList[index], index);
                },
                itemCount: notesList.length,
              ),
          ],
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: Showcase(
        key: _addNote,
        title: "Add Note",
        description: 'Tap to write and save a new note',
        targetShapeBorder: const CircleBorder(),
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
        child: FloatingActionButton(
          onPressed: () async {
            final result = await showNoteDialog();
            if (result == "added") {
              _init();
            }
          },
          shape: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide.none,
          ),
          backgroundColor: Colors.lightBlue[300],
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  getNoteItem(Note note, int index) {
    return Align(
      alignment: index % 2 != 0 ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onTap: () async {
          await updateNote(context, note);
          _init();
        },
        onLongPress: () async {
          final result = await showDeleteDialog();
          if (result != null && result == 'delete') {
            await dbHelper.deleteNote(note.id!);
            _init();
          }
        },
        child: Showcase(
          key: index == 0 ? _demoNote : _demoNote2,
          title: "Update or Delete Note",
          description:
          'Tap to update the item or Long press to delete it from the list',
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
          child: Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  //if notes image count is over then repeat start from 0
                  // index >= notesImageArray.length
                  //     ? notesImageArray[index - 7]
                  //     : notesImageArray[index],

                  notesImageArray[note.noteImageIndex],
                ),
              ),
            ),
            child: Text(
              note.msg,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  showNoteDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 35),
          child: SizedBox(
            width: double.infinity,
            child: NewNoteDialog("add", null, notesImageArray.length),
          ),
        );
      },
    );
  }

  getNoNoteFound() {
    return Column(
      children: [
        const SizedBox(
          height: 200,
        ),
        Image.asset(
          'assets/images/notes/sticky_note.png',
          width: 100,
          height: 100,
        ),
        Constants.sizeBoxH10,
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
            children: <InlineSpan>[
              const TextSpan(text: "Add your "),
              TextSpan(
                text: "first note\n ".toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const TextSpan(text: "and keep your ideas within reach.")
            ],
          ),
        ),
      ],
    );
  }

  updateNote(BuildContext context, Note note) async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity,
          child: NewNoteDialog("update", note, notesImageArray.length),
        ),
      ),
    );
    return result;
  }

  Future showDeleteDialog() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Dialog(
          insetPadding: EdgeInsets.all(45),
          child: SizedBox(
            width: double.infinity,
            child: DeleteNote(),
          ),
        );
      },
    );
  }
}
