import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.now,
    required this.onTap,
  });

  final Note note;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final snippet = note.body.trim().replaceAll(RegExp(r'\s+'), ' ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: chunkDecoration(radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.heavy(18),
            ),
            if (snippet.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                snippet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.heavy(14, weight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatNoteDate(note.updatedAt, now),
                    style: AppText.heavy(12, weight: FontWeight.w700),
                  ),
                ),
                if (note.imageCount > 0)
                  _Chip(icon: Icons.image_rounded, count: note.imageCount, color: AppColors.sky),
                if (note.pdfCount > 0) ...[
                  const SizedBox(width: 6),
                  _Chip(
                    icon: Icons.picture_as_pdf_rounded,
                    count: note.pdfCount,
                    color: AppColors.coral,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.count, required this.color});

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: chunkDecoration(color: color, radius: 10, shadow: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text('$count', style: AppText.heavy(12)),
        ],
      ),
    );
  }
}
