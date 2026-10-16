import 'dart:io';
import 'dart:typed_data';

import '../domain/attachment.dart';

class AttachmentTooLargeException implements Exception {
  const AttachmentTooLargeException(this.name, this.sizeBytes, this.maxBytes);

  final String name;
  final int sizeBytes;
  final int maxBytes;

  @override
  String toString() => '"$name" is too large (max ${maxBytes ~/ (1024 * 1024)} MB).';
}

/// Keeps a private copy of every attached file, so notes keep working even if
/// the original is moved or deleted.
abstract interface class AttachmentStorage {
  /// Copies [sourcePath] (or writes [bytes]) into storage.
  Future<Attachment> save({
    required String name,
    required AttachmentKind kind,
    String? sourcePath,
    Uint8List? bytes,
  });

  /// The stored file for [attachment] (it may not exist any more).
  File fileFor(Attachment attachment);

  /// Removes the stored file. Never throws.
  Future<void> delete(Attachment attachment);
}

/// Builds the storage for a signed-in user.
typedef AttachmentStorageFactory = AttachmentStorage Function(String userName);

class LocalAttachmentStorage implements AttachmentStorage {
  LocalAttachmentStorage(this.directory);

  /// Per-user folder, created on first use.
  final Directory directory;

  static const maxBytes = 15 * 1024 * 1024;

  static var _counter = 0;

  @override
  Future<Attachment> save({
    required String name,
    required AttachmentKind kind,
    String? sourcePath,
    Uint8List? bytes,
  }) async {
    if (sourcePath == null && bytes == null) {
      throw ArgumentError('Provide a sourcePath or bytes.');
    }

    final size = sourcePath != null
        ? await File(sourcePath).length()
        : bytes!.length;
    if (size > maxBytes) throw AttachmentTooLargeException(name, size, maxBytes);

    await directory.create(recursive: true);

    final id = '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';
    final storedName = '${id}_${_sanitize(name)}';
    final target = File(_join(storedName));

    if (sourcePath != null) {
      await File(sourcePath).copy(target.path);
    } else {
      await target.writeAsBytes(bytes!, flush: true);
    }

    return Attachment(
      id: id,
      name: name,
      storedName: storedName,
      kind: kind,
      sizeBytes: size,
    );
  }

  @override
  File fileFor(Attachment attachment) => File(_join(attachment.storedName));

  @override
  Future<void> delete(Attachment attachment) async {
    try {
      final file = fileFor(attachment);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best effort: a leftover file is harmless.
    }
  }

  String _join(String fileName) =>
      '${directory.path}${Platform.pathSeparator}$fileName';

  static String _sanitize(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_').trim();
    final safe = cleaned.isEmpty ? 'file' : cleaned;
    return safe.length > 80 ? safe.substring(safe.length - 80) : safe;
  }
}

/// Used where files can't be stored (e.g. in a browser).
class UnsupportedAttachmentStorage implements AttachmentStorage {
  const UnsupportedAttachmentStorage();

  @override
  Future<Attachment> save({
    required String name,
    required AttachmentKind kind,
    String? sourcePath,
    Uint8List? bytes,
  }) {
    throw UnsupportedError('Attachments are not supported on this platform.');
  }

  @override
  File fileFor(Attachment attachment) => File('');

  @override
  Future<void> delete(Attachment attachment) async {}
}
