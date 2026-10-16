import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/illustration_card.dart';

/// One onboarding page. Scrolls when space is tight (small phones, keyboard
/// open) instead of overflowing, and shrinks the artwork to what is left.
class IntroPage extends StatelessWidget {
  const IntroPage({
    super.key,
    required this.illustration,
    required this.title,
    this.body = '',
    this.extra,
  });

  /// Vertical room reserved for the title, body, spacing and optional field.
  static const _textBlockHeight = 250.0;
  static const _minArt = 110.0;
  static const _maxArt = 300.0;

  final Illustration illustration;
  final String title;
  final String body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final side = math.min(
          math.min(c.maxWidth, _maxArt),
          math.max(_minArt, c.maxHeight - _textBlockHeight),
        );

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IllustrationCard(illustration: illustration, maxSize: side),
                const SizedBox(height: 24),
                Text(title, textAlign: TextAlign.center, style: AppText.heavy(34)),
                const SizedBox(height: 12),
                if (body.isNotEmpty)
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: AppText.heavy(16, weight: FontWeight.w500),
                  ),
                ?extra,
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
