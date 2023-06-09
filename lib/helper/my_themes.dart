import 'package:flutter/material.dart';

import 'colors.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      onSurface: Colors.white,
    ),
    primaryColor: primaryColor,
    cardColor: Color(0xFF454545),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontFamily: 'Quicksand',
        fontWeight: FontWeight.w600,
      ),
    ),
    fontFamily: 'Quicksand',
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: ColorScheme.light(
      onSurface: dark,
    ),
    cardColor: Colors.white,
    primaryColor: primaryColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        color: dark,
        fontFamily: 'Quicksand',
        fontWeight: FontWeight.w600,
      ),
    ),
    fontFamily: 'Quicksand',
  );
}
