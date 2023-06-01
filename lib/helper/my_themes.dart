import 'package:flutter/material.dart';

import 'colors.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.dark(),
    primaryColor: Color(0xFF454545),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: ColorScheme.light(),
    primaryColor: Colors.white,
  );
}
