// ignore_for_file: deprecated_member_use

/* Purpose: Stores reusable components for front-end
  1. Textbox etc.
*/

import 'package:flutter/material.dart';

Widget customTextButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return Center(
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: 280,
        height: 40,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF002C93),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget customTextButtonGray({
  required String text,
  required VoidCallback onPressed,
}) {
  return Center(
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: 280,
        height: 40,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 201, 200, 200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget shortCustomTextButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return Center(
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SizedBox(
        width: 130,
        height: 40,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF002C93),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget miniCustomTextButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return Center(
    child: Container(
      child: SizedBox(
        width: 75,
        height: 30,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF002C93),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget materialsInput({required String text, required VoidCallback onPressed}) {
  return Center(
    child: SizedBox(
      width: 120,
      height: 45,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 12, 68, 198),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
            side: BorderSide(color: Colors.white, width: 1.0),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    ),
  );
}

Widget customTextField({
  //store in database OR authenticate
  required TextEditingController controller,
  required String labelText,
  IconData? icon,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Center(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: SizedBox(
            width: 280,
            height: 45,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: labelText,
                labelStyle: const TextStyle(
                  color: Color.fromARGB(255, 156, 163, 179),
                  fontSize: 15,
                ),
                prefixIcon:
                    icon != null
                        ? Padding(
                          padding: const EdgeInsets.only(left: 32, right: 23),
                          child: Icon(icon, color: Color(0xFF002C93), size: 20),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget quantitySelector({
  required int quantity,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Container(
        width: 300,
        height: 160,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter Quantity",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Color(0xFF002C93),
                      size: 35,
                    ),
                    onPressed: onDecrement,
                  ),
                ),
                Text(
                  '$quantity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Color(0xFF002C93),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF002C93),
                      size: 35,
                    ),
                    onPressed: onIncrement,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget quantitySelectorWithSave({
  required int quantity,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
  required VoidCallback onPressed,
  required VoidCallback onClose,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Container(
        width: 300,
        height: 230,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Placeholder to balance layout
                Text(
                  "Enter Quantity",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: onClose,
                ),
              ],
            ),

            const SizedBox(height: 5),
            Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Color(0xFF002C93),
                      size: 35,
                    ),
                    onPressed: onDecrement,
                  ),
                ),
                Text(
                  '$quantity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Color(0xFF002C93),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF002C93),
                      size: 35,
                    ),
                    onPressed: onIncrement,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            customTextButtonGray(text: "Save", onPressed: onPressed),
          ],
        ),
      ),
    ),
  );
}

void showDialogBox({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey, thickness: 1),
            ],
          ),
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
        actions: <Widget>[
          Center(
            child: customTextButtonForDialog(
              text: 'Okay',
              onPressed: () {
                onPressed();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget customTextButtonForDialog({
  required String text,
  required VoidCallback onPressed,
}) {
  return Center(
    child: SizedBox(
      width: 330,
      height: 45,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFFD9D9D9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}
