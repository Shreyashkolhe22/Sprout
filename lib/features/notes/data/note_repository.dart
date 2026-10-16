import '../domain/note.dart';

/// Where one user's notes are stored.
abstract interface class NoteRepository {
  Future<List<Note>> load();
  Future<void> save(List<Note> notes);
}

/// Keeps notes in memory only. Used by tests and previews.
class InMemoryNoteRepository implements NoteRepository {
  InMemoryNoteRepository({List<Note>? seed}) : _notes = [...?seed];

  List<Note> _notes;

  @override
  Future<List<Note>> load() async => List.of(_notes);

  @override
  Future<void> save(List<Note> notes) async {
    _notes = List.of(notes);
  }
}
