import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/dates.dart';
import 'package:flutter_application_1/features/habits/domain/habit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart';

void main() {
  final today = DateTime(2026, 10, 14);

  group('currentStreak', () {
    test('is 0 with no completions', () {
      expect(testHabit('h', today: today).currentStreak(today), 0);
    });

    test('counts back from today', () {
      final h = testHabit('h', today: today, doneDaysAgo: [0, 1, 2]);
      expect(h.currentStreak(today), 3);
    });

    test('is still alive when today is not done yet', () {
      final h = testHabit('h', today: today, doneDaysAgo: [1, 2]);
      expect(h.currentStreak(today), 2);
    });

    test('is broken after a missed day', () {
      final h = testHabit('h', today: today, doneDaysAgo: [2, 3, 4]);
      expect(h.currentStreak(today), 0);
    });

    test('stops at a gap', () {
      final h = testHabit('h', today: today, doneDaysAgo: [0, 1, 3, 4]);
      expect(h.currentStreak(today), 2);
    });
  });

  group('bestStreak', () {
    test('is 0 with no completions', () {
      expect(testHabit('h', today: today).bestStreak(), 0);
    });

    test('finds the longest run across the whole history', () {
      final h = testHabit('h', today: today, doneDaysAgo: [0, 5, 6, 7, 8, 20]);
      expect(h.bestStreak(), 4);
    });

    test('is not limited to a lookback window', () {
      final h = testHabit(
        'h',
        today: today,
        createdDaysAgo: 400,
        doneDaysAgo: [300, 301, 302, 303, 304],
      );
      expect(h.bestStreak(), 5);
    });
  });

  test('existsOn is false before the creation day', () {
    final h = testHabit('h', today: today, createdDaysAgo: 3);
    expect(h.existsOn(addDays(today, -4)), isFalse);
    expect(h.existsOn(addDays(today, -3)), isTrue);
    expect(h.existsOn(today), isTrue);
  });

  test('setDone adds and removes a day', () {
    final h = testHabit('h', today: today);
    h.setDone(today, true);
    expect(h.isDoneOn(today), isTrue);
    h.setDone(today, false);
    expect(h.isDoneOn(today), isFalse);
  });

  test('survives a JSON round trip', () {
    final original = Habit(
      id: 'abc',
      title: 'Read',
      goal: '15 pages',
      iconIndex: 3,
      color: const Color(0xFF7FE0B6),
      createdOn: DateTime(2026, 10, 1),
      completedDates: {'2026-10-02', '2026-10-01'},
    );

    final copy = Habit.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(copy.id, 'abc');
    expect(copy.title, 'Read');
    expect(copy.goal, '15 pages');
    expect(copy.iconIndex, 3);
    expect(copy.color.toARGB32(), 0xFF7FE0B6);
    expect(copy.createdOn, DateTime(2026, 10, 1));
    expect(copy.completedDates, {'2026-10-01', '2026-10-02'});
  });

  test('an unknown icon index falls back safely', () {
    final h = testHabit('h', today: today);
    final odd = Habit(
      id: 'x',
      title: 'x',
      goal: 'x',
      iconIndex: 999,
      color: Colors.red,
      createdOn: today,
    );
    expect(odd.icon, h.icon);
  });
}
