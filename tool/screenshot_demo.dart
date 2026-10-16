// Seeded demo of the app, used to take marketing screenshots with realistic data.
//
//   flutter run -t tool/screenshot_demo.dart
//
// Runs entirely in memory (nothing is saved) and signs in as "Alex".
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/utils/dates.dart';
import 'package:flutter_application_1/features/auth/data/session_repository.dart';
import 'package:flutter_application_1/features/habits/data/habit_repository.dart';
import 'package:flutter_application_1/features/habits/domain/habit.dart';
import 'package:flutter_application_1/features/notes/data/attachment_storage.dart';
import 'package:flutter_application_1/features/notes/data/note_repository.dart';
import 'package:flutter_application_1/features/notes/domain/attachment.dart';
import 'package:flutter_application_1/features/notes/domain/note.dart';

void main() {
  final today = dateOnly(DateTime.now());

  /// A habit with a current streak of [streak] days. If it isn't done today the
  /// streak counts back from yesterday.
  Habit habit(
    String id,
    String title,
    String goal,
    int icon,
    Color color,
    int streak, {
    bool doneToday = false,
    List<int> alsoDoneDaysAgo = const [],
  }) {
    final start = doneToday ? 0 : 1;
    final days = <int>{
      for (var i = start; i < start + streak; i++) i,
      ...alsoDoneDaysAgo,
    };
    return Habit(
      id: id,
      title: title,
      goal: goal,
      iconIndex: icon,
      color: color,
      createdOn: addDays(today, -60),
      completedDates: {for (final d in days) dateKey(addDays(today, -d))},
    );
  }

  final habits = [
    habit('water', 'Drink water', '8 glasses', 2, AppColors.sky, 12, doneToday: true),
    habit('read', 'Read', '15 pages', 1, AppColors.sun, 5, doneToday: true, alsoDoneDaysAgo: [8, 9, 10]),
    habit('stretch', 'Stretch', '5 minutes', 3, AppColors.lilac, 3, doneToday: true, alsoDoneDaysAgo: [6, 7]),
    habit('walk', 'Walk', '20 min outside', 5, AppColors.mint, 8),
    habit('journal', 'Journal', '3 lines before bed', 9, AppColors.coral, 21),
  ];

  Attachment file(String name, AttachmentKind kind, int size) => Attachment(
        id: name,
        name: name,
        storedName: name,
        kind: kind,
        sizeBytes: size,
      );

  Note note(String id, String title, String body, int hoursAgo,
      [List<Attachment> attachments = const []]) {
    final t = DateTime.now().subtract(Duration(hours: hoursAgo));
    return Note(
      id: id,
      title: title,
      body: body,
      createdAt: t,
      updatedAt: t,
      attachments: attachments,
    );
  }

  final notes = [
    note(
      '1',
      'Weekend trip plan',
      'Book the flights and the hotel, pack light, and call Mom about the train times.',
      2,
      [file('itinerary.pdf', AttachmentKind.pdf, 120000), file('map.png', AttachmentKind.image, 340000)],
    ),
    note(
      '2',
      'Book ideas',
      'Atomic Habits, The Midnight Library, Deep Work. Ask Sam for more recommendations.',
      26,
    ),
    note(
      '3',
      'Gym routine',
      'Mon: legs. Wed: push. Fri: pull. Stretch for five minutes after every session.',
      72,
      [file('routine.pdf', AttachmentKind.pdf, 85000)],
    ),
  ];

  runApp(
    SproutApp(
      session: InMemorySessionRepository(userName: 'Alex'),
      servicesFor: (_) => UserServices(
        habits: InMemoryHabitRepository(seed: habits),
        notes: InMemoryNoteRepository(seed: notes),
        attachments: const UnsupportedAttachmentStorage(),
      ),
    ),
  );
}
