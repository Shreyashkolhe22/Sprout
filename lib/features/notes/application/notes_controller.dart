import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/attachment_storage.dart';
import '../data/note_repository.dart';
import '../domain/note.dart';

/// Holds notes for the UI and persists every change.
class NotesController extends ChangeNotifier {
  NotesController(
    this._repository,
    this._storage, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final NoteRepository _repository;
  final AttachmentStorage _storage;
  final DateTime Function() _now;

  List<Note> _notes = [];
  bool _loaded = false;
  String _query = '';

  bool get isLoaded => _loaded;
  String get query => _query;

  DateTime get now => _now();

  /// Every note, most recently edited first.
  UnmodifiableListView<Note> get notes => UnmodifiableListView(_sorted(_notes));

  /// Notes matching the current search (title, text or attachment name).
  List<Note> get visibleNotes {
    final q = _query.trim().toLowerCase();
    final all = _sorted(_notes);
    if (q.isEmpty) return all;
    return all.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.body.toLowerCase().contains(q) ||
          n.attachments.any((a) => a.name.toLowerCase().contains(q));
    }).toList();
  }

  Note? byId(String id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  Future<void> load() async {
    _notes = await _repository.load();
    _loaded = true;
    notifyListeners();
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  /// Adds or replaces [note] (matched by id) and stamps it as edited now.
  /// Blank notes are ignored. Returns the stored note.
  Note? save(Note note) {
    if (note.isBlank) return null;
    final stamped = note.copyWith(updatedAt: _now());
    final index = _notes.indexWhere((n) => n.id == stamped.id);
    _notes = [..._notes];
    if (index == -1) {
      _notes.add(stamped);
    } else {
      _notes[index] = stamped;
    }
    _changed();
    return stamped;
  }

  /// Removes [note] and its attachment files.
  Future<void> delete(Note note) async {
    _notes = _notes.where((n) => n.id != note.id).toList();
    _changed();
    for (final a in note.attachments) {
      await _storage.delete(a);
    }
  }

  List<Note> _sorted(List<Note> notes) =>
      [...notes]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  void _changed() {
    unawaited(_persist());
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      await _repository.save(_notes);
    } catch (error) {
      debugPrint('Could not save notes: $error');
    }
  }
}
