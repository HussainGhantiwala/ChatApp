// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/Theme/theme.dart';

AppBar buildAppBar(BuildContext context) {
  final icon = CupertinoIcons.moon_stars;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    leading: Icon(
      Icons.arrow_back_ios,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      ThemeSwitcher(
        builder: (context) => IconButton(
          onPressed: (() {
            final theme = isDarkMode ? MyTheme.darkTheme : MyTheme.lightTheme;
            final switcher = ThemeSwitcher.of(context);
            switcher.changeTheme(theme: theme);
          }),
          icon: Icon(
            icon,
          ),
        ),
      )
    ],
  );
}
