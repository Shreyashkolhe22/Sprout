import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// An [Illustration] framed in the app's chunky card style.
///
/// The picture keeps its own aspect ratio and is fitted inside a
/// [maxSize] × [maxSize] box.
class IllustrationCard extends StatelessWidget {
  const IllustrationCard({
    super.key,
    required this.illustration,
    required this.maxSize,
    this.border = 2.5,
    this.shadow = 6,
    this.semanticLabel,
  });

  final Illustration illustration;
  final double maxSize;
  final double border;
  final double shadow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final a = illustration.aspect;
    final w = a >= 1 ? maxSize : maxSize * a;
    final h = a >= 1 ? maxSize / a : maxSize;
    // Slightly larger than the artwork's own corner radius so the frame never
    // shows a transparent corner.
    final radius = math.min(w, h) * 0.26;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.ink, width: border),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          if (shadow > 0)
            BoxShadow(color: AppColors.ink, offset: Offset(shadow, shadow)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(math.max(radius - border, 0)),
        child: Image.asset(
          illustration.asset,
          fit: BoxFit.cover,
          semanticLabel: semanticLabel,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppColors.sun,
            child: Center(child: Icon(Icons.image_not_supported_rounded)),
          ),
        ),
      ),
    );
  }
}
