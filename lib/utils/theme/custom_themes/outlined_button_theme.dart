import 'package:flutter/material.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static ButtonStyle _style({
    double elevation = 0,
    required Color foregroundColor,
    required Color borderColor,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    double verticalPadding = 16,
    double horizontalPadding = 20,
    double borderRadius = 14,
  }) {
    return OutlinedButton.styleFrom(
      elevation: elevation,
      foregroundColor: foregroundColor,
      side: BorderSide(color: borderColor),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static final OutlinedButtonThemeData lightOutlinedButtonTheme =
  OutlinedButtonThemeData(
    style: _style(
      foregroundColor: Colors.black,
      borderColor: Colors.grey,
    ),
  );

  static final OutlinedButtonThemeData darkOutlinedButtonTheme =
  OutlinedButtonThemeData(
    style: _style(
      foregroundColor: Colors.white,
      borderColor: Colors.grey,
    ),
  );
}
