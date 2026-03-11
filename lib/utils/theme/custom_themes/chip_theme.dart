import 'package:flutter/material.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData _theme({
    required Color labelColor,
    required Color selectedColor,
    required Color checkmarkColor,
    Color disabledColor = Colors.grey,
    double disabledOpacity = 0.4,
    double horizontalPadding = 12,
    double verticalPadding = 12,
  }) {
    return ChipThemeData(
      disabledColor:
      disabledColor.withValues(alpha: disabledOpacity * 255),
      labelStyle: TextStyle(color: labelColor),
      selectedColor: selectedColor,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      checkmarkColor: checkmarkColor,
    );
  }

  static final ChipThemeData lightChipTheme = _theme(
    labelColor: Colors.black,
    selectedColor: Colors.blue,
    checkmarkColor: Colors.white,
  );

  static final ChipThemeData darkChipTheme = _theme(
    labelColor: Colors.white,
    selectedColor: Colors.blue,
    checkmarkColor: Colors.white,
    disabledOpacity: 1,
  );
}
