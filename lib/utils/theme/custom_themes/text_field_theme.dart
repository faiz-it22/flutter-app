import 'package:flutter/material.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme _theme({
    required Color textColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color errorBorderColor,
    required Color focusedErrorBorderColor,
    Color iconColor = Colors.grey,
    double fontSize = 14,
    double borderRadius = 14,
    int errorMaxLines = 3,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(width: width, color: color),
        );

    return InputDecorationTheme(
      errorMaxLines: errorMaxLines,
      prefixIconColor: iconColor,
      suffixIconColor: iconColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: TextStyle(fontSize: fontSize, color: textColor),
      hintStyle: TextStyle(fontSize: fontSize, color: textColor),
      errorStyle: const TextStyle(fontStyle: FontStyle.normal),
      floatingLabelStyle:
      TextStyle(color: textColor.withValues(alpha: 0.8)),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(focusedBorderColor),
      errorBorder: border(errorBorderColor),
      focusedErrorBorder: border(focusedErrorBorderColor, width: 2),
    );
  }

  static final InputDecorationTheme lightInputDecorationTheme = _theme(
    textColor: Colors.black,
    borderColor: Colors.grey,
    focusedBorderColor: Colors.black12,
    errorBorderColor: Colors.red,
    focusedErrorBorderColor: Colors.orange,
  );

  static final InputDecorationTheme darkInputDecorationTheme = _theme(
    textColor: Colors.white,
    borderColor: Colors.grey,
    focusedBorderColor: Colors.white12,
    errorBorderColor: Colors.red,
    focusedErrorBorderColor: Colors.orange,
  );
}
