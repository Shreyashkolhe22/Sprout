import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/illustration_card.dart';
import '../application/notes_controller.dart';
import '../domain/note.dart';
import 'widgets/note_card.dart';

/// The Notes tab: search, list of notes and an empty state.
class NotesView extends StatelessWidget {
  const NotesView({
    super.key,
    required this.controller,
    required this.onOpenNote,
    required this.onNewNote,
  });

  final NotesController controller;
  final ValueChanged<Note> onOpenNote;
  final VoidCallback onNewNote;

  @override
  Widget build(BuildContext context) {
    final all = controller.notes;
    final visible = controller.visibleNotes;
    final searching = controller.query.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text('Notes', style: AppText.heavy(30))),
            if (all.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: chunkDecoration(color: AppColors.lilac, radius: 12, shadow: 3),
                child: Text('${all.length}', style: AppText.heavy(15)),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (all.isNotEmpty) ...[
          _SearchField(onChanged: controller.setQuery),
          const SizedBox(height: 16),
        ],
        if (all.isEmpty)
          _EmptyNotes(onNewNote: onNewNote)
        else if (visible.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: chunkDecoration(),
            child: Text(
              searching
                  ? 'No notes match "${controller.query.trim()}".'
                  : 'No notes.',
              style: AppText.heavy(15, weight: FontWeight.w600),
            ),
          ),
        for (final note in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: NoteCard(
              note: note,
              now: controller.now,
              onTap: () => onOpenNote(note),
            ),
          ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: 2.5),
        );

    return TextField(
      key: const Key('notes-search'),
      controller: _text,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: AppText.heavy(16, weight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Search notes',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _text,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _text.clear();
                    widget.onChanged('');
                  },
                ),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: border(AppColors.ink),
        focusedBorder: border(AppColors.tangerine),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onNewNote});

  final VoidCallback onNewNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const IllustrationCard(illustration: AppAssets.meditate, maxSize: 210),
        const SizedBox(height: 22),
        Text('No notes yet', textAlign: TextAlign.center, style: AppText.heavy(24)),
        const SizedBox(height: 8),
        Text(
          'Jot down thoughts, ideas or reminders.\n'
          'You can attach images and PDFs too.',
          textAlign: TextAlign.center,
          style: AppText.heavy(15, weight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        ChunkyButton(
          label: 'Write my first note',
          icon: Icons.edit_note_rounded,
          onPressed: onNewNote,
        ),
      ],
    );
  }
}
