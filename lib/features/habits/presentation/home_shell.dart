import 'package:flutter/material.dart';

import '../../focus/presentation/focus_screen.dart';
import '../../notes/application/notes_controller.dart';
import '../../notes/data/attachment_picker.dart';
import '../../notes/data/attachment_storage.dart';
import '../../notes/data/note_repository.dart';
import '../../notes/domain/note.dart';
import '../../notes/presentation/note_screen.dart';
import '../../notes/presentation/notes_view.dart';
import '../application/habit_controller.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import 'new_habit_sheet.dart';
import 'profile_sheet.dart';
import 'stats_view.dart';
import 'today_view.dart';
import 'widgets/sprout_bottom_nav.dart';

/// Main screen: owns the controllers and switches Today / Notes / Stats.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.userName,
    required this.habitRepository,
    required this.noteRepository,
    required this.attachmentStorage,
    required this.attachmentPicker,
    required this.onLogout,
  });

  final String userName;
  final HabitRepository habitRepository;
  final NoteRepository noteRepository;
  final AttachmentStorage attachmentStorage;
  final AttachmentPicker attachmentPicker;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  static const _today = 0;
  static const _notes = 1;
  static const _stats = 2;

  late final HabitController _habits =
      HabitController(widget.habitRepository)..load();
  late final NotesController _noteController =
      NotesController(widget.noteRepository, widget.attachmentStorage)..load();

  int _tab = _today;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _habits.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// If the app was backgrounded past midnight, "today" has moved on.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _habits.refresh();
  }

  // ---- habits

  Future<void> _openFocus(Habit habit) async {
    final finished = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FocusScreen(habit: habit)),
    );
    if (finished == true) _habits.markDone(habit);
  }

  Future<void> _addHabit() async {
    final habit = await NewHabitSheet.show(context, today: _habits.today);
    if (habit != null) _habits.add(habit);
  }

  void _removeHabit(Habit habit) {
    final index = _habits.remove(habit);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed "${habit.title}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _habits.restore(index, habit),
          ),
        ),
      );
  }

  // ---- notes

  Future<void> _openNote([Note? note]) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => NoteScreen(
          controller: _noteController,
          storage: widget.attachmentStorage,
          picker: widget.attachmentPicker,
          note: note,
        ),
      ),
    );
  }

  // ---- shared

  void _openProfile() {
    ProfileSheet.show(
      context,
      userName: widget.userName,
      habitCount: _habits.habits.length,
      dayStreak: _habits.dayStreak,
      bestStreak: _habits.bestStreak,
      onLogout: widget.onLogout,
    );
  }

  void _onAdd() => _tab == _notes ? _openNote() : _addHabit();

  Widget _body() {
    if (!_habits.isLoaded || !_noteController.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return switch (_tab) {
      _notes => NotesView(
          controller: _noteController,
          onOpenNote: _openNote,
          onNewNote: _openNote,
        ),
      _stats => StatsView(controller: _habits),
      _ => TodayView(
          controller: _habits,
          userName: widget.userName,
          onOpenHabit: _openFocus,
          onRemoveHabit: _removeHabit,
          onAddHabit: _addHabit,
          onOpenProfile: _openProfile,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_habits, _noteController]),
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(child: _body()),
          bottomNavigationBar: SproutBottomNav(
            currentIndex: _tab,
            onSelected: (i) => setState(() => _tab = i),
            onAdd: _onAdd,
            onProfile: _openProfile,
            addLabel: _tab == _notes ? 'Add note' : 'Add habit',
          ),
        );
      },
    );
  }
}
