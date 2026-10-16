import 'package:flutter_application_1/features/notes/data/prefs_note_repository.dart';
import 'package:flutter_application_1/features/notes/domain/attachment.dart';
import 'package:flutter_application_1/features/notes/domain/note.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final t0 = DateTime(2026, 10, 14, 9, 30);

  Future<SharedPreferences> prefs([Map<String, Object> initial = const {}]) {
    SharedPreferences.setMockInitialValues(initial);
    return SharedPreferences.getInstance();
  }

  Note note(String id, String title) => Note(
        id: id,
        title: title,
        body: 'body',
        createdAt: t0,
        updatedAt: t0,
        attachments: const [
          Attachment(
            id: 'a',
            name: 'doc.pdf',
            storedName: 'a_doc.pdf',
            kind: AttachmentKind.pdf,
            sizeBytes: 99,
          ),
        ],
      );

  test('load returns an empty list when nothing is saved', () async {
    final repo = PrefsNoteRepository(await prefs(), 'Sam');
    expect(await repo.load(), isEmpty);
  });

  test('notes and attachments survive a save and a fresh load', () async {
    final p = await prefs();
    await PrefsNoteRepository(p, 'Sam').save([note('1', 'Hello')]);

    final loaded = await PrefsNoteRepository(p, 'Sam').load();

    expect(loaded.single.title, 'Hello');
    expect(loaded.single.attachments.single.name, 'doc.pdf');
  });

  test('each user name gets its own notes', () async {
    final p = await prefs();
    await PrefsNoteRepository(p, 'Sam').save([note('1', 'Sams')]);

    expect(await PrefsNoteRepository(p, 'Alex').load(), isEmpty);
    expect((await PrefsNoteRepository(p, ' sam ').load()).single.title, 'Sams');
  });

  test('corrupt data starts empty instead of crashing', () async {
    final p = await prefs({PrefsNoteRepository.keyFor('Sam'): 'not json'});
    expect(await PrefsNoteRepository(p, 'Sam').load(), isEmpty);
  });
}
