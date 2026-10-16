import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppText {
  /// The app's single type voice: heavy, tight, ink-coloured.
  static TextStyle heavy(
    double size, {
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w900,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.15,
      letterSpacing: -0.2,
    );
  }
}
