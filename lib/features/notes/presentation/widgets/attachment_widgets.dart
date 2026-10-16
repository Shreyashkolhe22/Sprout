import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/attachment_storage.dart';
import '../../domain/attachment.dart';
import '../image_viewer_screen.dart';
import '../pdf_viewer_screen.dart';

/// All attachments of a note: image thumbnails first, then PDF rows.
///
/// Pass [onRemove] to show remove buttons (edit mode).
class AttachmentsSection extends StatelessWidget {
  const AttachmentsSection({
    super.key,
    required this.attachments,
    required this.storage,
    this.onRemove,
  });

  final List<Attachment> attachments;
  final AttachmentStorage storage;
  final ValueChanged<Attachment>? onRemove;

  void _open(BuildContext context, Attachment a) {
    final file = storage.fileFor(a);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('This file is missing from the device.')),
        );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => a.isImage
            ? ImageViewerScreen(file: file, title: a.name)
            : PdfViewerScreen(file: file, title: a.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = attachments.where((a) => a.isImage).toList();
    final pdfs = attachments.where((a) => a.isPdf).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          LayoutBuilder(
            builder: (context, c) {
              const gap = 10.0;
              final size = (c.maxWidth - gap * 2) / 3;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final a in images)
                    ImageAttachmentTile(
                      file: storage.fileFor(a),
                      size: size,
                      label: a.name,
                      onTap: () => _open(context, a),
                      onRemove: onRemove == null ? null : () => onRemove!(a),
                    ),
                ],
              );
            },
          ),
        if (images.isNotEmpty && pdfs.isNotEmpty) const SizedBox(height: 12),
        for (final a in pdfs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PdfAttachmentRow(
              attachment: a,
              onTap: () => _open(context, a),
              onRemove: onRemove == null ? null : () => onRemove!(a),
            ),
          ),
      ],
    );
  }
}

class ImageAttachmentTile extends StatelessWidget {
  const ImageAttachmentTile({
    super.key,
    required this.file,
    required this.size,
    required this.label,
    required this.onTap,
    this.onRemove,
  });

  final File file;
  final double size;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: chunkDecoration(radius: 16, shadow: 3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    cacheWidth: (size * 3).round(),
                    semanticLabel: label,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: AppColors.sky,
                      child: Center(child: Icon(Icons.broken_image_rounded)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: -8,
              right: -8,
              child: _RemoveButton(onTap: onRemove!),
            ),
        ],
      ),
    );
  }
}

class PdfAttachmentRow extends StatelessWidget {
  const PdfAttachmentRow({
    super.key,
    required this.attachment,
    required this.onTap,
    this.onRemove,
  });

  final Attachment attachment;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: chunkDecoration(radius: 16, shadow: 3),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: chunkDecoration(color: AppColors.coral, radius: 12, shadow: 0),
              child: const Icon(Icons.picture_as_pdf_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heavy(15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PDF · ${formatFileSize(attachment.sizeBytes)}',
                    style: AppText.heavy(12, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              _RemoveButton(onTap: onRemove!)
            else
              const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('remove-attachment'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.coral,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: const Icon(Icons.close_rounded, size: 16),
      ),
    );
  }
}
