import 'package:flutter/material.dart';

class MyTheme {
  static final primary = Colors.deepPurple;
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    primarySwatch: Colors.deepPurple,
    colorScheme: ColorScheme.dark(primary: primary),
    dividerColor: Colors.white,
    fontFamily: "UberMoveBold",
  );

  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: "UberMoveBold",
      primaryColor: Colors.deepPurple,
      dividerColor: Colors.black,
      colorScheme: ColorScheme.light(primary: primary));
}
