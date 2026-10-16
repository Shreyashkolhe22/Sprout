import 'package:flutter_application_1/core/utils/dates.dart';
import 'package:flutter_application_1/features/habits/application/habit_controller.dart';
import 'package:flutter_application_1/features/habits/data/habit_repository.dart';
import 'package:flutter_application_1/features/habits/domain/habit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart';

void main() {
  // A Wednesday.
  var now = DateTime(2026, 10, 14, 9, 30);
  DateTime today() => dateOnly(now);

  setUp(() => now = DateTime(2026, 10, 14, 9, 30));

  Future<HabitController> build({
    List<Habit> seed = const [],
    InMemoryHabitRepository? repository,
  }) async {
    final controller = HabitController(
      repository ?? InMemoryHabitRepository(seed: seed),
      now: () => now,
    );
    await controller.load();
    return controller;
  }

  test('starts empty, on today, with real (non-sample) data', () async {
    final c = await build();
    expect(c.isLoaded, isTrue);
    expect(c.habits, isEmpty);
    expect(c.selectedDate, today());
    expect(c.dayStreak, 0);
    expect(c.bestStreak, 0);
  });

  test('week runs Monday to Sunday', () async {
    final c = await build();
    expect(c.week.first, DateTime(2026, 10, 12));
    expect(c.week.last, DateTime(2026, 10, 18));
  });

  test('toggle flips completion for the selected day and notifies', () async {
    final a = testHabit('a', today: today());
    final c = await build(seed: [a]);
    var notified = 0;
    c.addListener(() => notified++);

    c.toggle(a);
    expect(a.isDoneOn(today()), isTrue);
    c.toggle(a);
    expect(a.isDoneOn(today()), isFalse);
    expect(notified, 2);
  });

  test('selectDate changes which day toggle affects', () async {
    final a = testHabit('a', today: today());
    final c = await build(seed: [a]);
    final yesterday = addDays(today(), -1);

    c.selectDate(yesterday);
    c.toggle(a);

    expect(a.isDoneOn(yesterday), isTrue);
    expect(a.isDoneOn(today()), isFalse);
  });

  test('future days cannot be selected or ticked', () async {
    final a = testHabit('a', today: today());
    final c = await build(seed: [a]);
    final tomorrow = addDays(today(), 1);

    c.selectDate(tomorrow);
    expect(c.selectedDate, today());

    c.toggle(a, tomorrow);
    expect(a.isDoneOn(tomorrow), isFalse);
  });

  test('days before a habit existed cannot be ticked', () async {
    final a = testHabit('a', today: today(), createdDaysAgo: 2);
    final c = await build(seed: [a]);
    final before = addDays(today(), -5);

    c.toggle(a, before);

    expect(a.isDoneOn(before), isFalse);
    expect(c.totalOn(before), 0);
    expect(c.habitsOn(before), isEmpty);
  });

  test('isPerfect requires every habit that existed that day', () async {
    final a = testHabit('a', today: today());
    final b = testHabit('b', today: today());
    final c = await build(seed: [a, b]);

    c.markDone(a);
    expect(c.isPerfect(today()), isFalse);
    c.markDone(b);
    expect(c.isPerfect(today()), isTrue);
  });

  test('a brand-new habit does not make earlier days look missed', () async {
    final old = testHabit('old', today: today(), doneDaysAgo: [1]);
    final fresh = testHabit('fresh', today: today(), createdDaysAgo: 0);
    final c = await build(seed: [old, fresh]);
    final yesterday = addDays(today(), -1);

    expect(c.totalOn(yesterday), 1);
    expect(c.isPerfect(yesterday), isTrue);
  });

  test('dayStreak counts days with at least one tick', () async {
    final c = await build(seed: [
      testHabit('a', today: today(), doneDaysAgo: [1, 2]),
      testHabit('b', today: today(), doneDaysAgo: [2]),
    ]);
    expect(c.dayStreak, 2);
  });

  test('streaks reset after a missed day (real, not static)', () async {
    final a = testHabit('a', today: today(), doneDaysAgo: [1, 2, 3]);
    final c = await build(seed: [a]);
    expect(a.currentStreak(c.today), 3);

    // two days later without ticking anything: yesterday is now missed
    now = DateTime(2026, 10, 16, 8);
    expect(c.today, DateTime(2026, 10, 16));
    expect(a.currentStreak(c.today), 0);
    expect(c.dayStreak, 0);
  });

  test('following today moves with the clock', () async {
    final c = await build();
    expect(c.selectedDate, DateTime(2026, 10, 14));
    now = DateTime(2026, 10, 15, 0, 5);
    expect(c.selectedDate, DateTime(2026, 10, 15));
  });

  test('weekAvailableDays ignores future days and pre-creation days', () async {
    final a = testHabit('a', today: today(), createdDaysAgo: 1);
    final c = await build(seed: [a]);
    // Mon 12, Tue 13 (created), Wed 14 (today) -> Tue + Wed
    expect(c.weekAvailableDays(a), 2);
  });

  test('remove returns the index and restore puts it back', () async {
    final a = testHabit('a', today: today());
    final b = testHabit('b', today: today());
    final c = await build(seed: [a, b]);

    final index = c.remove(a);
    expect(index, 0);
    expect(c.habits, [b]);

    c.restore(index, a);
    expect(c.habits, [a, b]);
  });

  test('changes are persisted through the repository', () async {
    final repo = InMemoryHabitRepository();
    final c = await build(repository: repo);

    c.add(testHabit('new', today: today()));
    await Future<void>.delayed(Duration.zero);

    expect((await repo.load()).map((h) => h.id), ['new']);
  });
}
