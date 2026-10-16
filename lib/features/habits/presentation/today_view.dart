import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/dates.dart';
import '../application/habit_controller.dart';
import '../domain/habit.dart';
import 'widgets/empty_habits.dart';
import 'widgets/habit_card.dart';
import 'widgets/progress_hero.dart';
import 'widgets/week_strip.dart';

class TodayView extends StatelessWidget {
  const TodayView({
    super.key,
    required this.controller,
    required this.userName,
    required this.onOpenHabit,
    required this.onRemoveHabit,
    required this.onAddHabit,
    required this.onOpenProfile,
  });

  final HabitController controller;
  final String userName;
  final ValueChanged<Habit> onOpenHabit;
  final ValueChanged<Habit> onRemoveHabit;
  final VoidCallback onAddHabit;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final today = controller.today;
    final selected = controller.selectedDate;
    final habits = controller.habitsOn(selected);
    final hasAnyHabit = controller.habits.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, $userName!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heavy(28),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${weekdayShort[today.weekday - 1]}, ${today.day} ${monthShort[today.month - 1]}',
                    style: AppText.heavy(15, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StreakChip(days: controller.dayStreak),
            const SizedBox(width: 10),
            GestureDetector(
              key: const Key('profile-button'),
              onTap: onOpenProfile,
              child: Container(
                width: 46,
                height: 46,
                decoration: chunkDecoration(radius: 14, shadow: 3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(AppAssets.logo, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ProgressHero(
          done: controller.doneOn(selected),
          total: controller.totalOn(selected),
          isToday: controller.isTodaySelected,
          hasAnyHabit: hasAnyHabit,
        ),
        const SizedBox(height: 18),
        WeekStrip(controller: controller),
        const SizedBox(height: 22),
        Text('Habits', style: AppText.heavy(22)),
        const SizedBox(height: 12),
        if (!hasAnyHabit)
          EmptyHabits(onAdd: onAddHabit)
        else if (habits.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: chunkDecoration(),
            child: Text(
              'You hadn\'t planted any habits yet on this day.',
              style: AppText.heavy(15, weight: FontWeight.w600),
            ),
          ),
        for (final habit in habits)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Dismissible(
              key: ValueKey(habit.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onRemoveHabit(habit),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                decoration: chunkDecoration(color: AppColors.coral, shadow: 0),
                child: const Icon(Icons.delete_outline_rounded, size: 30),
              ),
              child: HabitCard(
                habit: habit,
                done: habit.isDoneOn(selected),
                streak: habit.currentStreak(today),
                onTap: () => onOpenHabit(habit),
                onToggle: () {
                  HapticFeedback.lightImpact();
                  controller.toggle(habit);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$days day streak',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: chunkDecoration(color: AppColors.sun, radius: 14, shadow: 3),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 22,
              color: days > 0 ? AppColors.tangerine : AppColors.ink.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 4),
            Text('$days', style: AppText.heavy(17)),
          ],
        ),
      ),
    );
  }
}
