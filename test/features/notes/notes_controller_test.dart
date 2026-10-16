import 'package:flutter_application_1/features/notes/application/notes_controller.dart';
import 'package:flutter_application_1/features/notes/data/note_repository.dart';
import 'package:flutter_application_1/features/notes/domain/attachment.dart';
import 'package:flutter_application_1/features/notes/domain/note.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart';

void main() {
  var now = DateTime(2026, 10, 14, 9, 0);
  late FakeAttachmentStorage storage;

  setUp(() {
    now = DateTime(2026, 10, 14, 9, 0);
    storage = FakeAttachmentStorage();
  });

  Future<NotesController> build({NoteRepository? repository}) async {
    final c = NotesController(
      repository ?? InMemoryNoteRepository(),
      storage,
      now: () => now,
    );
    await c.load();
    return c;
  }

  Note draft(String title, {String body = '', List<Attachment> attachments = const []}) {
    return Note.create(now).copyWith(title: title, body: body, attachments: attachments);
  }

  test('starts empty', () async {
    final c = await build();
    expect(c.isLoaded, isTrue);
    expect(c.notes, isEmpty);
  });

  test('save stores the note and stamps the edit time', () async {
    final c = await build();
    final n = draft('A');
    now = DateTime(2026, 10, 14, 11, 0);

    final saved = c.save(n)!;

    expect(c.notes.single.id, n.id);
    expect(saved.updatedAt, DateTime(2026, 10, 14, 11, 0));
  });

  test('blank notes are ignored', () async {
    final c = await build();
    expect(c.save(Note.create(now)), isNull);
    expect(c.notes, isEmpty);
  });

  test('saving again updates in place instead of duplicating', () async {
    final c = await build();
    final first = c.save(draft('v1'))!;

    c.save(first.copyWith(title: 'v2'));

    expect(c.notes, hasLength(1));
    expect(c.notes.single.title, 'v2');
  });

  test('most recently edited note comes first', () async {
    final c = await build();
    now = DateTime(2026, 10, 14, 9, 0);
    final a = c.save(draft('a'))!;
    now = DateTime(2026, 10, 14, 10, 0);
    c.save(draft('b').copyWith());
    now = DateTime(2026, 10, 14, 11, 0);
    c.save(a.copyWith(body: 'touched')); // a is now newest

    expect(c.notes.map((n) => n.title), ['a', 'b']);
  });

  test('search matches title, body and attachment names, ignoring case', () async {
    final c = await build();
    c.save(draft('Groceries', body: 'Milk and eggs'));
    now = now.add(const Duration(minutes: 1));
    c.save(draft('Docs', attachments: [
      const Attachment(
        id: '1',
        name: 'Passport.PDF',
        storedName: '1_Passport.PDF',
        kind: AttachmentKind.pdf,
        sizeBytes: 10,
      ),
    ]));

    c.setQuery('GROCER');
    expect(c.visibleNotes.map((n) => n.title), ['Groceries']);
    c.setQuery('eggs');
    expect(c.visibleNotes.map((n) => n.title), ['Groceries']);
    c.setQuery('passport');
    expect(c.visibleNotes.map((n) => n.title), ['Docs']);
    c.setQuery('');
    expect(c.visibleNotes, hasLength(2));
  });

  test('delete removes the note and its stored files', () async {
    final c = await build();
    final att = await storage.save(name: 'x.png', kind: AttachmentKind.image, bytes: null, sourcePath: '/x');
    final note = c.save(draft('With file', attachments: [att]))!;

    await c.delete(note);

    expect(c.notes, isEmpty);
    expect(storage.deleted, [att]);
  });

  test('changes are persisted through the repository', () async {
    final repo = InMemoryNoteRepository();
    final c = await build(repository: repo);

    c.save(draft('persist me'));
    await Future<void>.delayed(Duration.zero);

    expect((await repo.load()).map((n) => n.title), ['persist me']);
  });

  test('notifies listeners on changes and on search', () async {
    final c = await build();
    var count = 0;
    c.addListener(() => count++);

    c.save(draft('x'));
    c.setQuery('q');
    c.setQuery('q'); // unchanged -> no notification

    expect(count, 2);
  });
}
