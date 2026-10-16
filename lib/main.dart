import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/user_key.dart';
import 'features/auth/data/session_repository.dart';
import 'features/habits/data/prefs_habit_repository.dart';
import 'features/notes/data/attachment_storage.dart';
import 'features/notes/data/prefs_note_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Attachments are real files, which a browser can't keep.
  final Directory? documents =
      kIsWeb ? null : await getApplicationDocumentsDirectory();

  runApp(
    SproutApp(
      session: PrefsSessionRepository(prefs),
      servicesFor: (userName) => UserServices(
        habits: PrefsHabitRepository(prefs, userName),
        notes: PrefsNoteRepository(prefs, userName),
        attachments: documents == null
            ? const UnsupportedAttachmentStorage()
            : LocalAttachmentStorage(
                Directory(
                  '${documents.path}${Platform.pathSeparator}attachments'
                  '${Platform.pathSeparator}${userStorageKey(userName)}',
                ),
              ),
      ),
    ),
  );
}
