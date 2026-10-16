import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/user_key.dart';
import '../domain/note.dart';
import 'note_repository.dart';

/// Stores one user's notes as JSON on the device.
class PrefsNoteRepository implements NoteRepository {
  PrefsNoteRepository(this._prefs, String userName) : _key = keyFor(userName);

  final SharedPreferences _prefs;
  final String _key;

  @visibleForTesting
  static String keyFor(String userName) => 'notes_v1/${userStorageKey(userName)}';

  @override
  Future<List<Note>> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final item in list) Note.fromJson(item as Map<String, dynamic>),
      ];
    } catch (error) {
      debugPrint('Could not read saved notes ($error); starting empty.');
      return [];
    }
  }

  @override
  Future<void> save(List<Note> notes) async {
    await _prefs.setString(
      _key,
      jsonEncode([for (final n in notes) n.toJson()]),
    );
  }
}
