import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/illustration_card.dart';

/// Shown on the Today tab until the user has added their first habit.
class EmptyHabits extends StatelessWidget {
  const EmptyHabits({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final side = math.min(c.maxWidth, 220.0);
        return Column(
          children: [
            const SizedBox(height: 8),
            IllustrationCard(
              illustration: AppAssets.couch,
              maxSize: side,
              semanticLabel: 'A ghost slumped on a messy couch',
            ),
            const SizedBox(height: 22),
            Text(
              'Nothing planted yet',
              textAlign: TextAlign.center,
              style: AppText.heavy(24),
            ),
            const SizedBox(height: 8),
            Text(
              'Add the habits you really want to keep.\n'
              'Your streaks will build from today.',
              textAlign: TextAlign.center,
              style: AppText.heavy(15, weight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ChunkyButton(
              label: 'Add my first habit',
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ],
        );
      },
    );
  }
}
