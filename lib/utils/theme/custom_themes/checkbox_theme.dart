import 'package:flutter/material.dart';

class TCheckboxTheme {
  TCheckboxTheme._();

  static CheckboxThemeData _theme({
    required Color checkColor,
    required Color fillColor,
    double borderRadius = 4,
  }) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      checkColor: WidgetStateProperty.resolveWith(
            (states) =>
        states.contains(WidgetState.selected) ? checkColor : Colors.black,
      ),
      fillColor: WidgetStateProperty.resolveWith(
            (states) =>
        states.contains(WidgetState.selected)
            ? fillColor
            : Colors.transparent,
      ),
    );
  }

  static final CheckboxThemeData lightCheckboxTheme = _theme(
    checkColor: Colors.white,
    fillColor: Colors.blue,
  );

  static final CheckboxThemeData darkCheckboxTheme = _theme(
    checkColor: Colors.white,
    fillColor: Colors.blue,
  );
}
