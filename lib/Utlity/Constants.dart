import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/dialogs/NewTaskDialog.dart';

class Constants {
  static EdgeInsets padding5 = const EdgeInsets.all(5);
  static EdgeInsets padding10 = const EdgeInsets.all(10);
  static EdgeInsets padding20 = const EdgeInsets.all(20);
  static EdgeInsets padding30 = const EdgeInsets.all(30);
  static EdgeInsets padding40 = const EdgeInsets.all(40);
  static SizedBox sizeBoxH5 = const SizedBox(
    height: 5,
  );
  static SizedBox sizeBoxH10 = const SizedBox(
    height: 10,
  );
  static SizedBox sizeBoxH20 = const SizedBox(
    height: 20,
  );
  static SizedBox sizeBoxH30 = const SizedBox(
    height: 30,
  );
  static SizedBox sizeBoxH40 = const SizedBox(
    height: 40,
  );
  static SizedBox sizeBoxW5 = const SizedBox(
    width: 5,
  );
  static SizedBox sizeBoxW10 = const SizedBox(
    width: 10,
  );
  static SizedBox sizeBoxW20 = const SizedBox(
    width: 20,
  );
  static SizedBox sizeBoxW30 = const SizedBox(
    width: 30,
  );
  static SizedBox sizeBoxW40 = const SizedBox(
    width: 40,
  );

  static const List<String> categoryList = ["All", "Personal", "Work"];

  static BorderRadius borderRadius5 =
      const BorderRadius.all(Radius.circular(5));
  static BorderRadius borderRadius10 =
      const BorderRadius.all(Radius.circular(10));
  static BorderRadius borderRadius20 =
      const BorderRadius.all(Radius.circular(20));

  //get the time from the selection dropdown
  static List remainderList = [
    "No Remainder",
    "1 minute",
    "2 minutes",
    "5 minutes",
    "10 minutes",
    "30 minutes",
    "1 hour",
    "1 day",
    "7 days"
  ];
  static List remainderTimeList = [1, 2, 5, 10, 30, 60, 1440, 10080];

  static getNoDataFound() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/todo/rest.png',
            width: 100,
            height: 100,
          ),
          Constants.sizeBoxH10,
          const Text(
            "Nothing To Do",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  static getNewTask(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity,
          child: NewTaskDialog("add", null, 0),
        ),
      ),
    );
    return result;
  }

  static getCommonTextField(
      String title,
      String hintText,
      TextEditingController controller,
      int minLines,
      int maxLines,
      int maxLength) {
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
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: Constants.borderRadius10,
            ),
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

  static getLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return const CircularProgressIndicator(
          color: Colors.blue,
        );
      },
    );
  }

  static hideLoader(BuildContext context) {
    Navigator.pop(context);
  }

  static getCommonDropDown(String title, List dropdownList, String selected,
      ValueChanged onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        DropdownButton(
          padding: EdgeInsets.zero,
          borderRadius: Constants.borderRadius10,
          dropdownColor: Colors.white,
          isDense: true,
          value: selected.isNotEmpty ? selected : null,
          items: dropdownList.map(
            (e) {
              return DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ));
            },
          ).toList(),
          isExpanded: true,
          style: const TextStyle(
            color: Colors.black,
          ),
          hint: Text(title),
          onChanged: (value) {
            onChanged(value);
          },
        ),
      ],
    );
  }

  static getFormattedDate(DateTime date) {
    DateFormat format = DateFormat('dd/MM/yyyy');
    // DateFormat format = DateFormat.yMMMd();
    return format.format(date);
  }

  static getFormattedDateTime(String date, String time) {
    return DateFormat('dd/MM/yyyy hh:mm aa').parse("$date $time");
    // return DateFormat('MMM dd, yyyy hh:mm aa').parse("$date $time");
  }

  static showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius5,
          ),
          margin: padding5,
          child: Text(
            msg,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  static showToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.white,
      backgroundColor: Colors.grey[700],
      fontSize: 14,
    );
  }

  static getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static getTransparentStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light),
    );
  }

  static getTransparentBottomBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
      ),
    );
  }
}
