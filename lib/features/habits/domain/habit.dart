import 'package:flutter/material.dart';

import '../../../core/utils/dates.dart';
import 'habit_icons.dart';

/// A daily habit and the days it was completed.
///
/// [completedDates] is mutable on purpose but should only be changed through
/// `HabitController`, which validates the change, persists it and notifies
/// listeners.
class Habit {
  Habit({
    required this.id,
    required this.title,
    required this.goal,
    required this.iconIndex,
    required this.color,
    required DateTime createdOn,
    Set<String>? completedDates,
  })  : createdOn = dateOnly(createdOn),
        completedDates = completedDates ?? {};

  factory Habit.create({
    required String title,
    required String goal,
    required int iconIndex,
    required Color color,
    required DateTime today,
  }) {
    return Habit(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      goal: goal,
      iconIndex: iconIndex,
      color: color,
      createdOn: today,
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      goal: json['goal'] as String,
      iconIndex: json['icon'] as int,
      color: Color(json['color'] as int),
      createdOn: DateTime.parse(json['createdOn'] as String),
      completedDates: {...(json['done'] as List).cast<String>()},
    );
  }

  final String id;
  final String title;
  final String goal;
  final int iconIndex;
  final Color color;

  /// First day this habit counts. Days before it are never "missed".
  final DateTime createdOn;
  final Set<String> completedDates;

  IconData get icon => HabitIcons.at(iconIndex);

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'goal': goal,
        'icon': iconIndex,
        'color': color.toARGB32(),
        'createdOn': dateKey(createdOn),
        'done': completedDates.toList()..sort(),
      };

  bool existsOn(DateTime day) => !dateOnly(day).isBefore(createdOn);

  bool isDoneOn(DateTime day) => completedDates.contains(dateKey(day));

  void setDone(DateTime day, bool value) {
    value ? completedDates.add(dateKey(day)) : completedDates.remove(dateKey(day));
  }

  /// Consecutive days completed, ending today. A streak is still alive if
  /// today is not done *yet* but yesterday was.
  int currentStreak(DateTime today) {
    var day = dateOnly(today);
    if (!isDoneOn(day)) day = addDays(day, -1);
    var count = 0;
    while (isDoneOn(day)) {
      count++;
      day = addDays(day, -1);
    }
    return count;
  }

  /// Longest run of consecutive completed days, over the whole history.
  int bestStreak() {
    if (completedDates.isEmpty) return 0;
    final days = completedDates.map((k) => dateOnly(DateTime.parse(k))).toList()
      ..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i] == addDays(days[i - 1], 1)) {
        run++;
        if (run > best) best = run;
      } else if (days[i] != days[i - 1]) {
        run = 1;
      }
    }
    return best;
  }
}
