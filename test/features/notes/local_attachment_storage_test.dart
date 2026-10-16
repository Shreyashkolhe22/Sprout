import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_application_1/features/notes/data/attachment_storage.dart';
import 'package:flutter_application_1/features/notes/domain/attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temp;
  late LocalAttachmentStorage storage;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('sprout_attach_test_');
    storage = LocalAttachmentStorage(Directory('${temp.path}/user'));
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<File> source(String name, List<int> bytes) async {
    final f = File('${temp.path}/$name');
    await f.writeAsBytes(bytes);
    return f;
  }

  test('copies a picked file into private storage', () async {
    final src = await source('photo.png', [1, 2, 3, 4, 5]);

    final a = await storage.save(
      name: 'photo.png',
      kind: AttachmentKind.image,
      sourcePath: src.path,
    );

    expect(a.name, 'photo.png');
    expect(a.sizeBytes, 5);
    expect(a.kind, AttachmentKind.image);
    final stored = storage.fileFor(a);
    expect(await stored.readAsBytes(), [1, 2, 3, 4, 5]);
    expect(stored.path, isNot(src.path));
  });

  test('the stored copy survives deleting the original', () async {
    final src = await source('keep.pdf', [9, 9, 9]);
    final a = await storage.save(
      name: 'keep.pdf',
      kind: AttachmentKind.pdf,
      sourcePath: src.path,
    );

    await src.delete();

    expect(await storage.fileFor(a).exists(), isTrue);
  });

  test('writes bytes when there is no source path', () async {
    final a = await storage.save(
      name: 'mem.pdf',
      kind: AttachmentKind.pdf,
      bytes: Uint8List.fromList([7, 7]),
    );
    expect(await storage.fileFor(a).readAsBytes(), [7, 7]);
  });

  test('two files with the same name do not collide', () async {
    final src = await source('same.png', [1]);
    final a = await storage.save(name: 'same.png', kind: AttachmentKind.image, sourcePath: src.path);
    final b = await storage.save(name: 'same.png', kind: AttachmentKind.image, sourcePath: src.path);

    expect(a.storedName, isNot(b.storedName));
    expect(storage.fileFor(a).path, isNot(storage.fileFor(b).path));
  });

  test('unsafe characters in the name are cleaned for the stored file', () async {
    final a = await storage.save(
      name: r'we/ird:na*me?.pdf',
      kind: AttachmentKind.pdf,
      bytes: Uint8List.fromList([1]),
    );

    expect(a.name, r'we/ird:na*me?.pdf'); // shown as picked
    expect(a.storedName, isNot(contains('/')));
    expect(a.storedName, isNot(contains(':')));
    expect(await storage.fileFor(a).exists(), isTrue);
  });

  test('refuses files over the size limit', () async {
    final big = Uint8List(LocalAttachmentStorage.maxBytes + 1);

    expect(
      () => storage.save(name: 'huge.pdf', kind: AttachmentKind.pdf, bytes: big),
      throwsA(isA<AttachmentTooLargeException>()),
    );
  });

  test('delete removes the file and never throws', () async {
    final a = await storage.save(
      name: 'x.png',
      kind: AttachmentKind.image,
      bytes: Uint8List.fromList([1]),
    );

    await storage.delete(a);
    expect(await storage.fileFor(a).exists(), isFalse);

    await storage.delete(a); // already gone: still fine
  });

  test('needs a source path or bytes', () {
    expect(
      () => storage.save(name: 'n', kind: AttachmentKind.image),
      throwsArgumentError,
    );
  });
}
