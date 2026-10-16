import 'package:flutter_application_1/features/habits/data/prefs_habit_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers.dart';

void main() {
  final today = DateTime(2026, 10, 14);

  Future<SharedPreferences> prefs([Map<String, Object> initial = const {}]) {
    SharedPreferences.setMockInitialValues(initial);
    return SharedPreferences.getInstance();
  }

  test('load returns an empty list when nothing is saved', () async {
    final repo = PrefsHabitRepository(await prefs(), 'Sam');
    expect(await repo.load(), isEmpty);
  });

  test('habits survive a save and a fresh load', () async {
    final p = await prefs();
    await PrefsHabitRepository(p, 'Sam').save([
      testHabit('a', today: today, doneDaysAgo: [0, 1, 2]),
    ]);

    // a brand-new repository instance, as after an app restart
    final loaded = await PrefsHabitRepository(p, 'Sam').load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'a');
    expect(loaded.single.currentStreak(today), 3);
  });

  test('each user name gets its own habits', () async {
    final p = await prefs();
    await PrefsHabitRepository(p, 'Sam').save([testHabit('sams', today: today)]);

    expect(await PrefsHabitRepository(p, 'Alex').load(), isEmpty);
    expect((await PrefsHabitRepository(p, 'Sam').load()).single.id, 'sams');
  });

  test('user name matching ignores case and surrounding spaces', () async {
    final p = await prefs();
    await PrefsHabitRepository(p, 'Sam').save([testHabit('a', today: today)]);

    final loaded = await PrefsHabitRepository(p, '  sam ').load();
    expect(loaded.single.id, 'a');
  });

  test('corrupt data starts empty instead of crashing', () async {
    final p = await prefs({PrefsHabitRepository.keyFor('Sam'): '{not json'});
    expect(await PrefsHabitRepository(p, 'Sam').load(), isEmpty);
  });
}
