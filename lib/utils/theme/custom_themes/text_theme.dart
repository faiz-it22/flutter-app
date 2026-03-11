import 'package:flutter/material.dart';

class TTextTheme {
  TTextTheme._();

  static TextStyle _style({
    required double size,
    required FontWeight weight,
    required Color color,
    double? opacity,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: opacity == null
          ? color
          : color.withValues(alpha: opacity * 255),
    );
  }

  static final TextTheme lightTextTheme = _buildTextTheme(Colors.black);
  static final TextTheme darkTextTheme  = _buildTextTheme(Colors.white);

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      headlineLarge: _style(size: 32, weight: FontWeight.bold, color: color),
      headlineMedium: _style(size: 24, weight: FontWeight.w600, color: color),
      headlineSmall: _style(size: 18, weight: FontWeight.w600, color: color),

      titleLarge: _style(size: 16, weight: FontWeight.w600, color: color),
      titleMedium: _style(size: 16, weight: FontWeight.w500, color: color),
      titleSmall: _style(size: 16, weight: FontWeight.w400, color: color),

      bodyLarge: _style(size: 14, weight: FontWeight.w500, color: color),
      bodyMedium: _style(size: 14, weight: FontWeight.normal, color: color),
      bodySmall: _style(
        size: 14,
        weight: FontWeight.w500,
        color: color,
        opacity: 0.5,
      ),

      labelLarge: _style(size: 12, weight: FontWeight.normal, color: color),
      labelMedium: _style(
        size: 12,
        weight: FontWeight.normal,
        color: color,
        opacity: 0.5,
      ),
    );
  }
}
