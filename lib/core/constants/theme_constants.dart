import 'package:flutter/material.dart';
import 'package:babyshophub/core/constants/dark_color_scheme.dart';
import 'package:babyshophub/core/constants/dark_theme_text.dart';
import 'package:babyshophub/core/constants/light_color_scheme.dart';
import 'package:babyshophub/core/constants/light_theme_text.dart';


ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.black,
    fontFamily: 'OpenSans',
    textTheme: lightTextTheme,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[600]!)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade300)),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent))));

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  colorScheme: darkColorScheme,
  fontFamily: 'OpenSans',
  textTheme: darkTextTheme,
  scaffoldBackgroundColor: Colors.black,
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade600),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green[600]!),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade300),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent.shade200),
    ),
  ),
);
