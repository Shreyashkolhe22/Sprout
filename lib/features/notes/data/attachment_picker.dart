import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// A file the user chose, before it is copied into app storage.
class PickedAttachment {
  const PickedAttachment({required this.name, this.path, this.bytes});

  final String name;

  /// Local path when the platform provides one.
  final String? path;

  /// File content when there is no local path.
  final Uint8List? bytes;
}

/// Lets the user choose images or PDFs. Abstracted so tests can fake it.
abstract interface class AttachmentPicker {
  Future<List<PickedAttachment>> pickImages();
  Future<List<PickedAttachment>> pickPdfs();
}

class FilePickerAttachmentPicker implements AttachmentPicker {
  const FilePickerAttachmentPicker();

  @override
  Future<List<PickedAttachment>> pickImages() =>
      _pick(type: FileType.image);

  @override
  Future<List<PickedAttachment>> pickPdfs() =>
      _pick(type: FileType.custom, extensions: const ['pdf']);

  Future<List<PickedAttachment>> _pick({
    required FileType type,
    List<String>? extensions,
  }) async {
    final files = await FilePicker.pickFiles(
      type: type,
      allowedExtensions: extensions,
    );

    final result = <PickedAttachment>[];
    for (final f in files) {
      final path = f.path;
      result.add(
        PickedAttachment(
          name: f.name,
          path: path,
          bytes: path == null ? await f.readAsBytes() : null,
        ),
      );
    }
    return result;
  }
}
