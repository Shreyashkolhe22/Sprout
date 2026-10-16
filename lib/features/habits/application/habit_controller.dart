import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/utils/dates.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';

/// Holds habit state for the UI and persists every change.
///
/// All "what day is it" questions go through [today], which reads the clock
/// each time, so the app stays correct if it is left open past midnight.
class HabitController extends ChangeNotifier {
  HabitController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final HabitRepository _repository;
  final DateTime Function() _now;

  List<Habit> _habits = [];
  bool _loaded = false;

  /// The day the user picked in the week strip; null means "follow today".
  DateTime? _picked;

  bool get isLoaded => _loaded;
  UnmodifiableListView<Habit> get habits => UnmodifiableListView(_habits);

  DateTime get today => dateOnly(_now());
  DateTime get selectedDate => _picked ?? today;
  bool get isTodaySelected => selectedDate == today;

  /// Monday–Sunday of the current week.
  List<DateTime> get week {
    final t = today;
    final monday = addDays(t, -(t.weekday - 1));
    return [for (var i = 0; i < 7; i++) addDays(monday, i)];
  }

  Future<void> load() async {
    _habits = await _repository.load();
    _loaded = true;
    notifyListeners();
  }

  /// Re-evaluates "today" (call when the app returns to the foreground).
  void refresh() => notifyListeners();

  // ---- queries

  /// Habits that already existed on [day].
  List<Habit> habitsOn(DateTime day) =>
      _habits.where((h) => h.existsOn(day)).toList();

  int totalOn(DateTime day) => _habits.where((h) => h.existsOn(day)).length;

  int doneOn(DateTime day) =>
      _habits.where((h) => h.existsOn(day) && h.isDoneOn(day)).length;

  bool isPerfect(DateTime day) {
    final total = totalOn(day);
    return total > 0 && doneOn(day) == total;
  }

  bool isFuture(DateTime day) => dateOnly(day).isAfter(today);

  /// Days in a row (ending today, or yesterday if today is still open) with
  /// at least one habit ticked.
  int get dayStreak {
    var day = today;
    if (doneOn(day) == 0) day = addDays(day, -1);
    var count = 0;
    // Bounded so a pathological data set can never spin forever.
    while (count < 3650 && doneOn(day) > 0) {
      count++;
      day = addDays(day, -1);
    }
    return count;
  }

  int get weekTicks => week.fold(0, (sum, d) => sum + doneOn(d));

  int get perfectDaysThisWeek => week.where(isPerfect).length;

  /// Longest streak any single habit has ever had.
  int get bestStreak =>
      _habits.fold(0, (best, h) => math.max(best, h.bestStreak()));

  /// Days of this week [habit] was done.
  int weekCompletions(Habit habit) => week.where(habit.isDoneOn).length;

  /// Days of this week that count for [habit]: not in the future and not
  /// before the habit was created.
  int weekAvailableDays(Habit habit) =>
      week.where((d) => !isFuture(d) && habit.existsOn(d)).length;

  // ---- commands

  /// Picks the day shown on the Today tab. Future days are ignored.
  void selectDate(DateTime day) {
    final d = dateOnly(day);
    if (isFuture(d)) return;
    _picked = d == today ? null : d;
    notifyListeners();
  }

  /// Flips completion. Ignored for future days and days before the habit
  /// existed, so streaks can't be faked.
  void toggle(Habit habit, [DateTime? day]) {
    final d = dateOnly(day ?? selectedDate);
    if (!_canEdit(habit, d)) return;
    habit.setDone(d, !habit.isDoneOn(d));
    _changed();
  }

  void markDone(Habit habit, [DateTime? day]) {
    final d = dateOnly(day ?? selectedDate);
    if (!_canEdit(habit, d)) return;
    habit.setDone(d, true);
    _changed();
  }

  void add(Habit habit) {
    _habits = [..._habits, habit];
    _changed();
  }

  /// Removes [habit] and returns its former index so it can be restored.
  int remove(Habit habit) {
    final index = _habits.indexOf(habit);
    if (index == -1) return -1;
    _habits = [..._habits]..removeAt(index);
    _changed();
    return index;
  }

  void restore(int index, Habit habit) {
    final copy = [..._habits];
    copy.insert(math.min(math.max(index, 0), copy.length), habit);
    _habits = copy;
    _changed();
  }

  bool _canEdit(Habit habit, DateTime day) =>
      !isFuture(day) && habit.existsOn(day);

  void _changed() {
    unawaited(_persist());
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      await _repository.save(_habits);
    } catch (error) {
      debugPrint('Could not save habits: $error');
    }
  }
}
