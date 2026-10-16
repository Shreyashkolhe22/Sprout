import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/illustration_card.dart';
import '../application/habit_controller.dart';
import '../domain/habit.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key, required this.controller});

  final HabitController controller;

  @override
  Widget build(BuildContext context) {
    final week = controller.week;
    final hasHabits = controller.habits.isNotEmpty;
    final best = controller.bestStreak;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your week', style: AppText.heavy(30)),
                  const SizedBox(height: 4),
                  Text(
                    best == 0
                        ? 'Tick a habit to start a streak.'
                        : 'Best streak: $best ${best == 1 ? 'day' : 'days'}',
                    style: AppText.heavy(15, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IllustrationCard(
              illustration: AppAssets.trophy,
              maxSize: 84,
              border: 2,
              shadow: 4,
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (!hasHabits)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: chunkDecoration(radius: 22, shadow: 5),
            child: Row(
              children: [
                IllustrationCard(
                  illustration: AppAssets.meditate,
                  maxSize: 72,
                  border: 2,
                  shadow: 3,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Nothing to chart yet. Add a habit and your week will fill in here.',
                    style: AppText.heavy(15, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
        else ...[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
            decoration: chunkDecoration(radius: 24, shadow: 6),
            child: SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final day in week)
                    Expanded(
                      child: _Bar(
                        label: weekdayShort[day.weekday - 1].substring(0, 1),
                        done: controller.doneOn(day),
                        total: controller.totalOn(day),
                        future: controller.isFuture(day),
                        highlighted: day == controller.today,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '$best',
                  label: 'best streak',
                  color: AppColors.sun,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: '${controller.weekTicks}',
                  label: 'ticks this week',
                  color: AppColors.mint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: '${controller.perfectDaysThisWeek}',
                  label: 'perfect days',
                  color: AppColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('By habit', style: AppText.heavy(22)),
          const SizedBox(height: 12),
          for (final habit in controller.habits)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HabitRatio(
                habit: habit,
                done: controller.weekCompletions(habit),
                available: controller.weekAvailableDays(habit),
                streak: habit.currentStreak(controller.today),
              ),
            ),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.done,
    required this.total,
    required this.future,
    required this.highlighted,
  });

  final String label;
  final int done;
  final int total;
  final bool future;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final fraction = (future || total == 0) ? 0.0 : done / total;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          future ? '' : '$done',
          style: AppText.heavy(12, weight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: 8 + 100 * fraction,
          decoration: BoxDecoration(
            color: future
                ? Colors.transparent
                : highlighted
                    ? AppColors.tangerine
                    : AppColors.lilac,
            border: Border.all(
              color: AppColors.ink.withValues(alpha: future ? 0.25 : 1),
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppText.heavy(13)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: chunkDecoration(color: color, radius: 18),
      child: Column(
        children: [
          Text(value, style: AppText.heavy(28)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.heavy(12, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HabitRatio extends StatelessWidget {
  const _HabitRatio({
    required this.habit,
    required this.done,
    required this.available,
    required this.streak,
  });

  final Habit habit;
  final int done;
  final int available;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final fraction = available == 0 ? 0.0 : math.min(done / available, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: chunkDecoration(radius: 18, shadow: 3),
      child: Row(
        children: [
          Icon(habit.icon, size: 22),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(
              habit.title,
              overflow: TextOverflow.ellipsis,
              style: AppText.heavy(15),
            ),
          ),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.ink, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: habit.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$done/$available', style: AppText.heavy(14)),
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
    );
  }
}
