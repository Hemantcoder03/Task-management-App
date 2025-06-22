import 'package:flutter/material.dart';
import 'package:todo_list/Utlity/Constants.dart';

class DeleteNote extends StatefulWidget {
  const DeleteNote({super.key});

  @override
  State<DeleteNote> createState() => _DeleteNoteState();
}

class _DeleteNoteState extends State<DeleteNote> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Constants.borderRadius20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Image.asset(
              'assets/images/todo/delete.png',
              // 'assets/images/todo/delete_anim.gif',
              width: 50,
              height: 50,
            ),
          ),
          const Text(
            "Delete Note",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Text("Sure you want to delete."),
          Constants.sizeBoxH20,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStateColor.transparent,
                  side: WidgetStatePropertyAll(
                    BorderSide(
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                ),
                onPressed: () {
                  if(mounted){
                    Constants.hideLoader(context);
                  }
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              FilledButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Colors.blue,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context,'delete');
                },
                child: const Text("Delete"),
              ),
            ],
          ),
          Constants.sizeBoxH20,
        ],
      ),
    );
  }
}
