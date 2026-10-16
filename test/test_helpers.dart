import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/app.dart';
import 'package:flutter_application_1/features/auth/data/session_repository.dart';
import 'package:flutter_application_1/features/habits/data/habit_repository.dart';
import 'package:flutter_application_1/features/habits/domain/habit.dart';
import 'package:flutter_application_1/features/notes/data/attachment_picker.dart';
import 'package:flutter_application_1/features/notes/data/attachment_storage.dart';
import 'package:flutter_application_1/features/notes/data/note_repository.dart';
import 'package:flutter_application_1/features/notes/domain/attachment.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a habit that was created [createdDaysAgo] days before [today] and
/// completed on the given [doneDaysAgo] offsets.
Habit testHabit(
  String id, {
  required DateTime today,
  int createdDaysAgo = 30,
  List<int> doneDaysAgo = const [],
}) {
  final created = DateTime(today.year, today.month, today.day - createdDaysAgo);
  final habit = Habit(
    id: id,
    title: id,
    goal: 'Goal',
    iconIndex: 0,
    color: Colors.red,
    createdOn: created,
  );
  for (final d in doneDaysAgo) {
    habit.setDone(DateTime(today.year, today.month, today.day - d), true);
  }
  return habit;
}

/// Storage that never touches the disk: records what was saved / deleted.
class FakeAttachmentStorage implements AttachmentStorage {
  final List<Attachment> saved = [];
  final List<Attachment> deleted = [];
  int _next = 0;

  @override
  Future<Attachment> save({
    required String name,
    required AttachmentKind kind,
    String? sourcePath,
    Uint8List? bytes,
  }) async {
    final id = 'fake-${_next++}';
    final attachment = Attachment(
      id: id,
      name: name,
      storedName: '${id}_$name',
      kind: kind,
      sizeBytes: bytes?.length ?? 2048,
    );
    saved.add(attachment);
    return attachment;
  }

  @override
  File fileFor(Attachment attachment) => File('/fake/${attachment.storedName}');

  @override
  Future<void> delete(Attachment attachment) async {
    deleted.add(attachment);
  }
}

/// Picker that returns whatever the test queues up.
class FakeAttachmentPicker implements AttachmentPicker {
  List<PickedAttachment> images = [];
  List<PickedAttachment> pdfs = [];

  @override
  Future<List<PickedAttachment>> pickImages() async => List.of(images);

  @override
  Future<List<PickedAttachment>> pickPdfs() async => List.of(pdfs);
}

/// The app wired to in-memory storage that, like the real thing, keeps one
/// set of habits / notes per user name and outlives log out / log in.
class TestHarness {
  TestHarness({String? signedInAs})
      : session = InMemorySessionRepository(userName: signedInAs);

  final InMemorySessionRepository session;
  final FakeAttachmentPicker picker = FakeAttachmentPicker();
  final FakeAttachmentStorage storage = FakeAttachmentStorage();
  final Map<String, UserServices> _services = {};

  UserServices servicesFor(String name) {
    return _services.putIfAbsent(
      name.trim().toLowerCase(),
      () => UserServices(
        habits: InMemoryHabitRepository(),
        notes: InMemoryNoteRepository(),
        attachments: storage,
      ),
    );
  }

  Widget build() => SproutApp(
        session: session,
        servicesFor: servicesFor,
        attachmentPicker: picker,
      );
}

/// A tall screen so lazily built lists show everything.
void tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> finishOnboarding(WidgetTester tester, String name) async {
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }
  await tester.enterText(find.byType(TextField), name);
  await tester.tap(find.text("Let's grow"));
  await tester.pumpAndSettle();
}

/// Adds a habit with the + button while on the Today tab.
Future<void> addHabit(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const Key('nav-add')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, name);
  await tester.tap(find.text('Create'));
  await tester.pumpAndSettle();
}
