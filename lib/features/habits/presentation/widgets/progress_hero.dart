import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/illustration_card.dart';
import '../../../../core/widgets/progress_ring.dart';

/// Top card on the Today tab: progress ring, a message, and Pip reacting to
/// how the day is going.
class ProgressHero extends StatelessWidget {
  const ProgressHero({
    super.key,
    required this.done,
    required this.total,
    required this.isToday,
    this.hasAnyHabit = true,
  });

  final int done;
  final int total;
  final bool isToday;

  /// False until the user has created their first habit.
  final bool hasAnyHabit;

  bool get _allDone => total > 0 && done == total;

  String get _message {
    if (!hasAnyHabit) return 'Add your first habit to get started.';
    if (total == 0) return 'No habits on this day.';
    if (_allDone) return 'All done. You absolute legend!';
    if (!isToday && done == 0) return 'That day slipped by. Today is a fresh start.';
    if (done == 0) return "A fresh day. Let's tick off the first one!";
    if (done * 2 >= total) return 'More than halfway. Keep rolling!';
    return 'Nice start. Keep it going!';
  }

  Illustration get _art {
    if (total == 0) return AppAssets.couch;
    if (_allDone) return AppAssets.celebrate;
    if (!isToday && done == 0) return AppAssets.sad;
    if (done == 0) return AppAssets.wake;
    return AppAssets.checklist;
  }

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: chunkDecoration(
        color: _allDone ? AppColors.mint : Colors.white,
        radius: 26,
        shadow: 6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: ProgressRing(
              progress: progress,
              child: Text('$done/$total', style: AppText.heavy(18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? "Today's goal" : 'That day',
                  style: AppText.heavy(13, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(_message, style: AppText.heavy(15)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IllustrationCard(
            illustration: _art,
            maxSize: 78,
            border: 2,
            shadow: 3,
          ),
        ],
      ),
    );
  }
}
