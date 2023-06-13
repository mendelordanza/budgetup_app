import 'package:flutter/material.dart';

import 'colors.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      onSurface: Colors.white,
      primary: primaryColor,
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
      actionsIconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    fontFamily: 'Quicksand',
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: secondaryColor,
      linearTrackColor: Colors.grey,
    ),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: ColorScheme.light(
      onSurface: dark,
      primary: primaryColor,
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
      actionsIconTheme: IconThemeData(
        color: dark,
      ),
    ),
    fontFamily: 'Quicksand',
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: secondaryColor,
      linearTrackColor: Colors.grey,
    ),
  );
}
