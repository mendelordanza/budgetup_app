import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomFloatingButton extends StatelessWidget {
  final Function() onPressed;

  const CustomFloatingButton({required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      onPressed: onPressed,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Icon(
        Iconsax.add,
        color: Colors.white,
      ),
    );
  }
}
