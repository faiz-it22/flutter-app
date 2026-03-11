import 'package:flutter/material.dart';

class TTextButtonTheme {
  TTextButtonTheme._();

  static ButtonStyle _style({
    required Color foregroundColor,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    bool underline = false,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor,
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }

  static final TextButtonThemeData lightTextButtonTheme = TextButtonThemeData(
    style: _style(
      foregroundColor: Colors.deepPurple,
      underline: true, // Change as needed
    ),
  );

  static final TextButtonThemeData darkTextButtonTheme = TextButtonThemeData(
    style: _style(
      foregroundColor: Colors.deepPurpleAccent,
      underline: true, // Change as needed
    ),
  );
}
