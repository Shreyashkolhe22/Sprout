import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/user_key.dart';
import '../domain/habit.dart';
import 'habit_repository.dart';

/// Stores one user's habits as JSON on the device.
///
/// Each user name gets its own key, so logging out and back in as the same
/// name restores that user's habits.
class PrefsHabitRepository implements HabitRepository {
  PrefsHabitRepository(this._prefs, String userName)
      : _key = keyFor(userName);

  final SharedPreferences _prefs;
  final String _key;

  @visibleForTesting
  static String keyFor(String userName) => 'habits_v1/${userStorageKey(userName)}';

  @override
  Future<List<Habit>> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final item in list) Habit.fromJson(item as Map<String, dynamic>),
      ];
    } catch (error) {
      // Corrupt or incompatible data: start clean rather than crash on launch.
      debugPrint('Could not read saved habits ($error); starting empty.');
      return [];
    }
  }

  @override
  Future<void> save(List<Habit> habits) async {
    await _prefs.setString(
      _key,
      jsonEncode([for (final h in habits) h.toJson()]),
    );
  }
}
