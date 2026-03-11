import 'package:flutter/material.dart';

class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static ButtonStyle _style({
    double elevation = 0,
    Color foregroundColor = Colors.white,
    Color backgroundColor = Colors.blue,
    Color disabledForegroundColor = Colors.grey,
    Color disabledBackgroundColor = Colors.grey,
    Color borderColor = Colors.blue,
    double verticalPadding = 18,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    double borderRadius = 12,
  }) {
    return ElevatedButton.styleFrom(
      elevation: elevation,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      side: BorderSide(color: borderColor),
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: _style(),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: _style(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );
}