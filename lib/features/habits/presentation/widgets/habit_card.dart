import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text.dart';
import '../../domain/habit.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.done,
    required this.streak,
    required this.onTap,
    required this.onToggle,
  });

  final Habit habit;
  final bool done;
  final int streak;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: chunkDecoration(
          color: done ? Colors.white.withValues(alpha: 0.7) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: chunkDecoration(color: habit.color, radius: 14, shadow: 0),
              child: Icon(habit.icon, color: AppColors.ink, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: AppText.heavy(18).copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationThickness: 2.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          habit.goal,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.heavy(13, weight: FontWeight.w500),
                        ),
                      ),
                      if (streak > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: AppColors.tangerine,
                        ),
                        Text('$streak', style: AppText.heavy(13)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              key: Key('check-${habit.title}'),
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: done ? AppColors.mint : Colors.white,
                    border: Border.all(color: AppColors.ink, width: 2.5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: AnimatedScale(
                    scale: done ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: const Icon(Icons.check_rounded, size: 26),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
