import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/notes/data/attachment_picker.dart';
import 'package:flutter_application_1/features/notes/domain/attachment.dart';
import 'package:flutter_application_1/features/notes/presentation/widgets/attachment_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

Future<void> _openNotesTab(WidgetTester tester) async {
  await tester.tap(find.text('Notes'));
  await tester.pumpAndSettle();
}

/// Opens the editor with the + button (on the Notes tab) and fills it in.
Future<void> _newNote(
  WidgetTester tester, {
  String title = '',
  String body = '',
}) async {
  await tester.tap(find.byKey(const Key('nav-add')));
  await tester.pumpAndSettle();
  if (title.isNotEmpty) {
    await tester.enterText(find.byKey(const Key('note-title')), title);
  }
  if (body.isNotEmpty) {
    await tester.enterText(find.byKey(const Key('note-body')), body);
  }
  await tester.pump();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('save-note')));
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('note-back')));
  await tester.pumpAndSettle();
}

Future<void> _attach(WidgetTester tester, Key option) async {
  await tester.tap(find.byKey(const Key('attach-button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(option));
  await tester.pumpAndSettle();
}

Future<TestHarness> _signedIn(WidgetTester tester) async {
  tallScreen(tester);
  final harness = TestHarness(signedInAs: 'Sam');
  await tester.pumpWidget(harness.build());
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  testWidgets('notes tab starts empty with a call to action', (tester) async {
    await _signedIn(tester);
    await _openNotesTab(tester);

    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Write my first note'), findsOneWidget);
  });

  testWidgets('write a note, save it, read it back in the list', (tester) async {
    await _signedIn(tester);
    await _openNotesTab(tester);

    await _newNote(tester, title: 'Groceries', body: 'Milk\nEggs\nBread');
    await _save(tester);

    // saved -> read mode shows the content
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.textContaining('Eggs'), findsOneWidget);

    await _back(tester);
    expect(find.text('Groceries'), findsOneWidget); // card in the list
    expect(find.text('No notes yet'), findsNothing);
  });

  testWidgets('edit an existing note', (tester) async {
    await _signedIn(tester);
    await _openNotesTab(tester);
    await _newNote(tester, title: 'Plan', body: 'first draft');
    await _save(tester);

    await tester.tap(find.byKey(const Key('edit-note')));
    await tester.pumpAndSettle();
    expect(find.text('Edit note'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('note-body')), 'second draft');
    await _save(tester);

    expect(find.text('second draft'), findsOneWidget);
    expect(find.text('first draft'), findsNothing);
  });

  testWidgets('a blank note is not saved', (tester) async {
    await _signedIn(tester);
    await _openNotesTab(tester);

    await _newNote(tester);
    await _save(tester);

    expect(find.textContaining('Add a title, some text or an attachment'),
        findsOneWidget);
    expect(find.text('New note'), findsOneWidget); // still editing
  });

  testWidgets('attach an image and a PDF, then they show on the note',
      (tester) async {
    final harness = await _signedIn(tester);
    harness.picker.images = [const PickedAttachment(name: 'photo.png', path: '/x/photo.png')];
    harness.picker.pdfs = [const PickedAttachment(name: 'invoice.pdf', path: '/x/invoice.pdf')];
    await _openNotesTab(tester);

    await _newNote(tester, title: 'Receipts');
    await _attach(tester, const Key('attach-image'));
    await _attach(tester, const Key('attach-pdf'));

    expect(find.byType(ImageAttachmentTile), findsOneWidget);
    expect(find.byType(PdfAttachmentRow), findsOneWidget);
    expect(find.text('invoice.pdf'), findsOneWidget);
    expect(harness.storage.saved.map((a) => a.kind),
        [AttachmentKind.image, AttachmentKind.pdf]);

    await _save(tester);
    // still there in read mode
    expect(find.byType(ImageAttachmentTile), findsOneWidget);
    expect(find.byType(PdfAttachmentRow), findsOneWidget);
    expect(harness.storage.deleted, isEmpty);

    await _back(tester);
    expect(find.text('Receipts'), findsOneWidget);
  });

  testWidgets('removing an unsaved attachment deletes its file at once',
      (tester) async {
    final harness = await _signedIn(tester);
    harness.picker.pdfs = [const PickedAttachment(name: 'a.pdf', path: '/x/a.pdf')];
    await _openNotesTab(tester);

    await _newNote(tester, title: 'Temp');
    await _attach(tester, const Key('attach-pdf'));
    expect(find.byType(PdfAttachmentRow), findsOneWidget);

    await tester.tap(find.byKey(const Key('remove-attachment')));
    await tester.pumpAndSettle();

    expect(find.byType(PdfAttachmentRow), findsNothing);
    expect(harness.storage.deleted, hasLength(1));
  });

  testWidgets('removing a saved attachment deletes the file only after Save',
      (tester) async {
    final harness = await _signedIn(tester);
    harness.picker.pdfs = [const PickedAttachment(name: 'keep.pdf', path: '/x/keep.pdf')];
    await _openNotesTab(tester);
    await _newNote(tester, title: 'Docs');
    await _attach(tester, const Key('attach-pdf'));
    await _save(tester);

    await tester.tap(find.byKey(const Key('edit-note')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('remove-attachment')));
    await tester.pumpAndSettle();
    expect(harness.storage.deleted, isEmpty); // not yet

    await _save(tester);
    expect(harness.storage.deleted, hasLength(1));
    expect(find.byType(PdfAttachmentRow), findsNothing);
  });

  testWidgets('discarding a new note removes files attached to it',
      (tester) async {
    final harness = await _signedIn(tester);
    harness.picker.images = [const PickedAttachment(name: 'p.png', path: '/x/p.png')];
    await _openNotesTab(tester);

    await _newNote(tester, title: 'Draft');
    await _attach(tester, const Key('attach-image'));

    await tester.tap(find.byKey(const Key('note-back'))); // close
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(harness.storage.deleted, hasLength(1));
    expect(find.text('No notes yet'), findsOneWidget);
  });

  testWidgets('"Keep editing" keeps the draft', (tester) async {
    await _signedIn(tester);
    await _openNotesTab(tester);

    await _newNote(tester, title: 'Keep me');
    await tester.tap(find.byKey(const Key('note-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('save-note')), findsOneWidget);
    expect(find.text('Keep me'), findsOneWidget);
  });

  testWidgets('delete a note and its attachments', (tester) async {
    final harness = await _signedIn(tester);
    harness.picker.images = [const PickedAttachment(name: 'p.png', path: '/x/p.png')];
    await _openNotesTab(tester);
    await _newNote(tester, title: 'Bye');
    await _attach(tester, const Key('attach-image'));
    await _save(tester);

    await tester.tap(find.byKey(const Key('delete-note')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this note?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No notes yet'), findsOneWidget);
    expect(harness.storage.deleted, hasLength(1));
  });

  testWidgets('search filters notes by title, text and attachment name',
      (tester) async {
    final harness = await _signedIn(tester);
    harness.picker.pdfs = [const PickedAttachment(name: 'tax-return.pdf', path: '/x/t.pdf')];
    await _openNotesTab(tester);

    await _newNote(tester, title: 'Workout', body: 'legs day');
    await _save(tester);
    await _back(tester);
    await _newNote(tester, title: 'Paperwork');
    await _attach(tester, const Key('attach-pdf'));
    await _save(tester);
    await _back(tester);

    await tester.enterText(find.byKey(const Key('notes-search')), 'legs');
    await tester.pumpAndSettle();
    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Paperwork'), findsNothing);

    await tester.enterText(find.byKey(const Key('notes-search')), 'tax');
    await tester.pumpAndSettle();
    expect(find.text('Paperwork'), findsOneWidget);
    expect(find.text('Workout'), findsNothing);

    await tester.enterText(find.byKey(const Key('notes-search')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('No notes match'), findsOneWidget);
  });

  testWidgets('notes belong to the user and return after log out / log in',
      (tester) async {
    tallScreen(tester);
    final harness = TestHarness();
    await tester.pumpWidget(harness.build());
    await finishOnboarding(tester, 'Sam');
    await _openNotesTab(tester);
    await _newNote(tester, title: 'Sam secret');
    await _save(tester);
    await _back(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    await finishOnboarding(tester, 'Alex');
    await _openNotesTab(tester);
    expect(find.text('Sam secret'), findsNothing);
    expect(find.text('No notes yet'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await finishOnboarding(tester, 'Sam');
    await _openNotesTab(tester);
    expect(find.text('Sam secret'), findsOneWidget);
  });

  testWidgets('the + button adds a habit on Today but a note on Notes',
      (tester) async {
    await _signedIn(tester);

    await tester.tap(find.byKey(const Key('nav-add')));
    await tester.pumpAndSettle();
    expect(find.text('Plant a new habit'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // dismiss the sheet
    await tester.pumpAndSettle();

    await _openNotesTab(tester);
    await tester.tap(find.byKey(const Key('nav-add')));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsOneWidget);
  });
}
