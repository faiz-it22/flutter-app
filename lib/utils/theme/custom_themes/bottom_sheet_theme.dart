import 'package:flutter/material.dart';

class TBottomSheetTheme {
  TBottomSheetTheme._();

  static BottomSheetThemeData _theme({
    required Color backgroundColor,
    bool showDragHandle = true,
    double borderRadius = 16,
  }) {
    return BottomSheetThemeData(
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor,
      modalBackgroundColor: backgroundColor,
      constraints: const BoxConstraints(minWidth: double.infinity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static final BottomSheetThemeData lightBottomSheetTheme =
  _theme(backgroundColor: Colors.white);

  static final BottomSheetThemeData darkBottomSheetTheme =
  _theme(backgroundColor: Colors.black);
}
