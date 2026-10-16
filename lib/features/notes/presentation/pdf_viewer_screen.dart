import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text.dart';

/// In-app PDF reader with pinch-to-zoom and a page counter.
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.file, required this.title});

  final File file;
  final String title;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final PdfControllerPinch _controller = PdfControllerPinch(
    document: PdfDocument.openFile(widget.file.path),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: AppText.heavy(16),
        ),
        actions: [
          PdfPageNumber(
            controller: _controller,
            builder: (context, state, page, pagesCount) {
              if (state != PdfLoadingState.success || pagesCount == null) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: chunkDecoration(
                    color: AppColors.sun,
                    radius: 12,
                    shadow: 2,
                  ),
                  child: Text('$page / $pagesCount', style: AppText.heavy(13)),
                ),
              );
            },
          ),
        ],
      ),
      body: PdfViewPinch(
        controller: _controller,
        backgroundDecoration: const BoxDecoration(color: AppColors.cream),
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not open this PDF.',
                textAlign: TextAlign.center,
                style: AppText.heavy(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
