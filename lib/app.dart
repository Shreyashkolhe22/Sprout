import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/session_repository.dart';
import 'features/habits/data/habit_repository.dart';
import 'features/habits/presentation/home_shell.dart';
import 'features/notes/data/attachment_picker.dart';
import 'features/notes/data/attachment_storage.dart';
import 'features/notes/data/note_repository.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

/// Everything that is stored per signed-in user.
class UserServices {
  const UserServices({
    required this.habits,
    required this.notes,
    required this.attachments,
  });

  final HabitRepository habits;
  final NoteRepository notes;
  final AttachmentStorage attachments;
}

typedef UserServicesFactory = UserServices Function(String userName);

class SproutApp extends StatelessWidget {
  const SproutApp({
    super.key,
    required this.session,
    required this.servicesFor,
    this.attachmentPicker = const FilePickerAttachmentPicker(),
  });

  /// Remembers who is signed in.
  final SessionRepository session;

  /// Creates the storage for a given user.
  final UserServicesFactory servicesFor;

  /// Lets the user choose images and PDFs to attach to notes.
  final AttachmentPicker attachmentPicker;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sprout',
      theme: AppTheme.light,
      home: _AppRoot(
        session: session,
        servicesFor: servicesFor,
        attachmentPicker: attachmentPicker,
      ),
    );
  }
}

/// Shows onboarding when logged out and the app when signed in.
class _AppRoot extends StatefulWidget {
  const _AppRoot({
    required this.session,
    required this.servicesFor,
    required this.attachmentPicker,
  });

  final SessionRepository session;
  final UserServicesFactory servicesFor;
  final AttachmentPicker attachmentPicker;

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  String? _userName;
  UserServices? _services;

  @override
  void initState() {
    super.initState();
    final saved = widget.session.userName;
    if (saved != null) _open(saved);
  }

  void _open(String name) {
    _userName = name;
    _services = widget.servicesFor(name);
  }

  Future<void> _signIn(String name) async {
    await widget.session.signIn(name);
    if (!mounted) return;
    setState(() => _open(name));
  }

  Future<void> _signOut() async {
    await widget.session.signOut();
    if (!mounted) return;
    setState(() {
      _userName = null;
      _services = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = _userName;
    final services = _services;
    if (name == null || services == null) {
      return OnboardingScreen(onFinished: _signIn);
    }
    return HomeShell(
      key: ValueKey(name),
      userName: name,
      habitRepository: services.habits,
      noteRepository: services.notes,
      attachmentStorage: services.attachments,
      attachmentPicker: widget.attachmentPicker,
      onLogout: _signOut,
    );
  }
}
