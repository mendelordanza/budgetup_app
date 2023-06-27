import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformProgressIndicator extends StatelessWidget {
  final Color? color;

  PlatformProgressIndicator({
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return CircularProgressIndicator();
    } else {
      return CupertinoActivityIndicator(
        color: color,
      );
    }
  }
}
