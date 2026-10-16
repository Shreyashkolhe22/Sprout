import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_text.dart';

/// Full-screen image with pinch-to-zoom.
class ImageViewerScreen extends StatelessWidget {
  const ImageViewerScreen({super.key, required this.file, required this.title});

  final File file;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: AppText.heavy(16, color: Colors.white),
        ),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 6,
        child: Center(
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.broken_image_rounded,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
