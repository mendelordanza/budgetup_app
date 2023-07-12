import 'package:flutter/material.dart';

import 'custom_button.dart';

class CustomActionDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> actions;

  CustomActionDialog(
      {required this.title,
      required this.description,
      required this.actions,
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
      actions: actions,
    );
  }
}
