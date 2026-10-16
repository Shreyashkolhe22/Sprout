import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The app's signature look: flat colour, thick ink outline, hard shadow.
BoxDecoration chunkDecoration({
  Color color = Colors.white,
  double radius = 20,
  double shadow = 4,
}) {
  return BoxDecoration(
    color: color,
    border: Border.all(color: AppColors.ink, width: 2.5),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      if (shadow > 0)
        BoxShadow(color: AppColors.ink, offset: Offset(shadow, shadow)),
    ],
  );
}
