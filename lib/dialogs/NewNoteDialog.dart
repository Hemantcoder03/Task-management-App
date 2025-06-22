import 'package:flutter/material.dart';
import 'package:todo_list/Utlity/Strings.dart';
import 'package:todo_list/db/DBHelper.dart';
import 'package:todo_list/model/NoteModel.dart';

import '../Utlity/Constants.dart';
import 'dart:math';

class NewNoteDialog extends StatefulWidget {
  NewNoteDialog(this.addOrUpdate,this.note,this.noteListLength, {super.key});

  String addOrUpdate;
  Note? note;
  int noteListLength;

  @override
  State<NewNoteDialog> createState() => _NewNoteDialogState();
}

class _NewNoteDialogState extends State<NewNoteDialog>
    with TickerProviderStateMixin {
  final TextEditingController _noteTextField = TextEditingController();
  DBHelper dbHelper = DBHelper.instance;

  //animation in button
  late final AnimationController _addBtnAnimation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  //get random number and assign to the note
  Random num = Random();

  @override
  void initState() {
    super.initState();

    if(widget.note != null){
      _noteTextField.text = widget.note!.msg;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Center(
            child: Text(
              "Add Note",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Constants.getCommonTextField("", "Enter Note", _noteTextField, 2, 2,40),
          Constants.sizeBoxH20,
          AnimatedBuilder(
            animation: _addBtnAnimation,
            builder: (BuildContext context, Widget? child) {
              final value = _addBtnAnimation.value;
              final sineValue = sin(5 * 2 * pi * value);
              return Transform.translate(
                offset: Offset(sineValue * 10, 0),
                child: InkWell(
                  onTap: () async {
                    if (_noteTextField.text.isEmpty) {
                      Constants.showToast(context, "Please Enter Note");
                    } else {
                      if (widget.addOrUpdate == "add") {
                        
                        int isInserted = await dbHelper.createNote(Note(null,
                            _noteTextField.text, DateTime.now().toString(),num.nextInt(widget.noteListLength)));
                        if (mounted && isInserted > 0) {
                          Constants.showSnackBar(
                              context, "Note added successfully");
                        } else {
                          if (mounted) {
                            Constants.showSnackBar(
                                context, Strings.somethingWentWrong);
                          }
                        }
                        Navigator.pop(context, "added");
                      }
                      else{
                        int isUpdated = await dbHelper.updateNote(widget.note!.id!, _noteTextField.text);
                        if (mounted && isUpdated > 0) {
                          Constants.showSnackBar(
                              context, "Note updated successfully");
                        } else {
                          if (mounted) {
                            Constants.showSnackBar(
                                context, Strings.somethingWentWrong);
                          }
                        }
                        Navigator.pop(context, "updated");
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: Constants.padding10,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: Constants.borderRadius10,
                    ),
                    child: Text(
                      widget.addOrUpdate == 'update' ? "UPDATE NOW" : "ADD NOW",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
