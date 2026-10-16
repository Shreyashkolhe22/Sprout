import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/dates.dart';
import '../../application/habit_controller.dart';

/// Mon–Sun chips. Perfect days are green, the selected day is inked and
/// future days are dimmed and can't be selected.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.controller});

  final HabitController controller;

  @override
  Widget build(BuildContext context) {
    final week = controller.week;
    return Row(
      children: [
        for (var i = 0; i < week.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _DayChip(day: week[i], controller: controller)),
        ],
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.controller});

  final DateTime day;
  final HabitController controller;

  @override
  Widget build(BuildContext context) {
    final future = controller.isFuture(day);
    final selected = day == controller.selectedDate;
    final bg = selected
        ? AppColors.ink
        : controller.isPerfect(day)
            ? AppColors.mint
            : Colors.white;
    final fg = selected ? Colors.white : AppColors.ink;

    return Opacity(
      opacity: future ? 0.4 : 1,
      child: GestureDetector(
        onTap: future ? null : () => controller.selectDate(day),
        child: Container(
          height: 60,
          decoration: chunkDecoration(color: bg, radius: 14, shadow: selected ? 0 : 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekdayShort[day.weekday - 1].substring(0, 1),
                style: AppText.heavy(12, color: fg, weight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text('${day.day}', style: AppText.heavy(16, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
