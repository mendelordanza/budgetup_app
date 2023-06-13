import 'package:flutter/material.dart';

import '../../helper/colors.dart';

class CustomButton extends StatelessWidget {
  final Function() onPressed;
  final Widget child;
  final Color? color;

  CustomButton({
    required this.onPressed,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.0,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
