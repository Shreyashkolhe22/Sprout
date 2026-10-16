import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../application/notes_controller.dart';
import '../data/attachment_picker.dart';
import '../data/attachment_storage.dart';
import '../domain/attachment.dart';
import '../domain/note.dart';
import 'widgets/attachment_widgets.dart';

/// Reads, creates and edits one note.
///
/// A new note opens straight in edit mode. An existing note opens in read
/// mode with an Edit button. Files attached while editing are only kept once
/// the note is saved; discarding removes them again.
class NoteScreen extends StatefulWidget {
  const NoteScreen({
    super.key,
    required this.controller,
    required this.storage,
    required this.picker,
    this.note,
  });

  final NotesController controller;
  final AttachmentStorage storage;
  final AttachmentPicker picker;

  /// null to create a new note.
  final Note? note;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late final TextEditingController _title =
      TextEditingController(text: widget.note?.title ?? '');
  late final TextEditingController _body =
      TextEditingController(text: widget.note?.body ?? '');

  late Note? _saved = widget.note;
  late List<Attachment> _attachments = [...?widget.note?.attachments];
  late bool _editing = widget.note == null;

  /// Attached during this edit session: deleted again if discarded.
  final List<Attachment> _added = [];

  /// Removed during this edit session: deleted for real once saved.
  final List<Attachment> _removed = [];

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(_refresh);
    _body.addListener(_refresh);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _isNew => _saved == null;

  bool get _dirty {
    if (!_editing) return false;
    final base = _saved;
    if (base == null) {
      return _title.text.trim().isNotEmpty ||
          _body.text.trim().isNotEmpty ||
          _attachments.isNotEmpty;
    }
    return _title.text != base.title ||
        _body.text != base.body ||
        _added.isNotEmpty ||
        _removed.isNotEmpty;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- actions

  Future<void> _attach() async {
    final kind = await showModalBottomSheet<AttachmentKind>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: AppColors.ink, width: 2.5),
      ),
      builder: (_) => const _AttachSheet(),
    );
    if (kind == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final picked = kind == AttachmentKind.image
          ? await widget.picker.pickImages()
          : await widget.picker.pickPdfs();

      for (final file in picked) {
        final attachment = await widget.storage.save(
          name: file.name,
          kind: kind,
          sourcePath: file.path,
          bytes: file.bytes,
        );
        _added.add(attachment);
        _attachments = [..._attachments, attachment];
      }
    } on AttachmentTooLargeException catch (e) {
      if (mounted) _snack(e.toString());
    } on UnsupportedError {
      if (mounted) _snack('Attachments are not supported on this device.');
    } catch (_) {
      if (mounted) _snack('Could not attach that file.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _removeAttachment(Attachment a) {
    setState(() {
      _attachments = _attachments.where((x) => x != a).toList();
      if (_added.remove(a)) {
        // never saved: drop the file straight away
        widget.storage.delete(a);
      } else {
        _removed.add(a);
      }
    });
  }

  Future<void> _save() async {
    final base = _saved ?? Note.create(widget.controller.now);
    final draft = base.copyWith(
      title: _title.text.trim(),
      body: _body.text.trimRight(),
      attachments: _attachments,
    );
    if (draft.isBlank) {
      _snack('Add a title, some text or an attachment first.');
      return;
    }

    final stored = widget.controller.save(draft);
    for (final a in _removed) {
      await widget.storage.delete(a);
    }
    _removed.clear();
    _added.clear();

    if (!mounted) return;
    setState(() {
      _saved = stored;
      _editing = false;
    });
  }

  /// Throws away this session's changes and returns to the saved version.
  Future<void> _discard() async {
    for (final a in _added) {
      await widget.storage.delete(a);
    }
    _added.clear();
    _removed.clear();
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits to this note have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _cancelEditing() async {
    if (_dirty && !await _confirmDiscard()) return;
    await _discard();
    if (!mounted) return;
    final base = _saved;
    if (base == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _title.text = base.title;
      _body.text = base.body;
      _attachments = [...base.attachments];
      _editing = false;
    });
  }

  Future<void> _delete() async {
    final note = _saved;
    if (note == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this note?'),
        content: Text(
          note.attachments.isEmpty
              ? 'This can\'t be undone.'
              : 'Its ${note.attachments.length} attachment(s) will be deleted too. '
                  'This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.controller.delete(note);
    if (mounted) Navigator.of(context).pop();
  }

  // ---- build

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard()) {
          await _discard();
          if (mounted) Navigator.of(this.context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: _editing ? _buildEditor() : _buildReader(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            key: const Key('note-back'),
            icon: Icon(_editing ? Icons.close_rounded : Icons.arrow_back_rounded),
            onPressed: () => _editing
                ? _cancelEditing()
                : Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              _editing ? (_isNew ? 'New note' : 'Edit note') : 'Note',
              style: AppText.heavy(20),
            ),
          ),
          if (_editing) ...[
            IconButton(
              key: const Key('attach-button'),
              tooltip: 'Attach image or PDF',
              icon: const Icon(Icons.attach_file_rounded),
              onPressed: _busy ? null : _attach,
            ),
            const SizedBox(width: 4),
            _SmallButton(
              key: const Key('save-note'),
              label: 'Save',
              color: AppColors.tangerine,
              onTap: _busy ? null : _save,
            ),
          ] else ...[
            IconButton(
              key: const Key('edit-note'),
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _editing = true),
            ),
            IconButton(
              key: const Key('delete-note'),
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReader() {
    final note = _saved!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(note.displayTitle, style: AppText.heavy(30)),
        const SizedBox(height: 6),
        Text(
          'Edited ${formatNoteDate(note.updatedAt, widget.controller.now)}',
          style: AppText.heavy(13, weight: FontWeight.w600),
        ),
        if (note.body.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          SelectableText(
            note.body,
            style: AppText.heavy(17, weight: FontWeight.w500).copyWith(height: 1.45),
          ),
        ],
        if (note.attachments.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Attachments', style: AppText.heavy(18)),
          const SizedBox(height: 12),
          AttachmentsSection(
            attachments: note.attachments,
            storage: widget.storage,
          ),
        ],
      ],
    );
  }

  Widget _buildEditor() {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: 2.5),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          key: const Key('note-title'),
          controller: _title,
          maxLength: 80,
          textCapitalization: TextCapitalization.sentences,
          style: AppText.heavy(20),
          decoration: InputDecoration(
            hintText: 'Title',
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: border(AppColors.ink),
            focusedBorder: border(AppColors.tangerine),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('note-body'),
          controller: _body,
          minLines: 8,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: AppText.heavy(17, weight: FontWeight.w500).copyWith(height: 1.4),
          decoration: InputDecoration(
            hintText: 'Write something…',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: border(AppColors.ink),
            focusedBorder: border(AppColors.tangerine),
          ),
        ),
        const SizedBox(height: 20),
        Text('Attachments', style: AppText.heavy(18)),
        const SizedBox(height: 12),
        if (_busy) ...[
          const LinearProgressIndicator(
            color: AppColors.tangerine,
            backgroundColor: AppColors.cream,
          ),
          const SizedBox(height: 12),
        ],
        if (_attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: chunkDecoration(shadow: 0, radius: 16),
            child: Row(
              children: [
                const Icon(Icons.attach_file_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap the paperclip above to add images or PDFs.',
                    style: AppText.heavy(14, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
        else
          AttachmentsSection(
            attachments: _attachments,
            storage: widget.storage,
            onRemove: _removeAttachment,
          ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: chunkDecoration(color: color, radius: 14, shadow: 3),
          child: Text(label, style: AppText.heavy(15)),
        ),
      ),
    );
  }
}

class _AttachSheet extends StatelessWidget {
  const _AttachSheet();

  @override
  Widget build(BuildContext context) {
    Widget option({
      required Key key,
      required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required AttachmentKind kind,
    }) {
      return GestureDetector(
        key: key,
        onTap: () => Navigator.of(context).pop(kind),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: chunkDecoration(radius: 18, shadow: 3),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: chunkDecoration(color: color, radius: 14, shadow: 0),
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.heavy(17)),
                    Text(
                      subtitle,
                      style: AppText.heavy(13, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attach to note', style: AppText.heavy(24)),
            const SizedBox(height: 16),
            option(
              key: const Key('attach-image'),
              icon: Icons.image_rounded,
              title: 'Image',
              subtitle: 'Choose pictures from your gallery',
              color: AppColors.sky,
              kind: AttachmentKind.image,
            ),
            const SizedBox(height: 12),
            option(
              key: const Key('attach-pdf'),
              icon: Icons.picture_as_pdf_rounded,
              title: 'PDF',
              subtitle: 'Choose a PDF document',
              color: AppColors.coral,
              kind: AttachmentKind.pdf,
            ),
          ],
        ),
      ),
    );
  }
}
