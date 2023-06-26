import 'package:flutter/material.dart';

import 'custom_button.dart';

class DeleteDialog extends StatelessWidget {
  final String title;
  final String description;
  final Function() onPositive;
  final Function() onNegative;

  DeleteDialog(
      {required this.title,
      required this.description,
      required this.onPositive,
      required this.onNegative,
      super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(title),
      content: Text(description),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            8.0,
            0.0,
            8.0,
            8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                onPressed: onNegative,
                child: Text(
                  "No",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              SizedBox(
                height: 44.0,
                child: OutlinedButton(
                  onPressed: () {
                    onPositive();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    side: BorderSide(
                      width: 1.0,
                      color: Theme.of(context).primaryColor,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
