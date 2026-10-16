import 'dart:convert';

import 'package:flutter_application_1/features/notes/domain/attachment.dart';
import 'package:flutter_application_1/features/notes/domain/note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 10, 14, 9, 30);

  Attachment attachment(String id, AttachmentKind kind, {String name = 'f'}) {
    return Attachment(
      id: id,
      name: name,
      storedName: '${id}_$name',
      kind: kind,
      sizeBytes: 1234,
    );
  }

  test('a fresh note is blank until it has content', () {
    final note = Note.create(t0);
    expect(note.isBlank, isTrue);
    expect(note.copyWith(title: '  ').isBlank, isTrue);
    expect(note.copyWith(body: 'hi').isBlank, isFalse);
    expect(
      note.copyWith(attachments: [attachment('a', AttachmentKind.pdf)]).isBlank,
      isFalse,
    );
  });

  test('displayTitle falls back sensibly', () {
    final note = Note.create(t0);
    expect(note.displayTitle, 'Untitled note');
    expect(note.copyWith(title: ' Plan ').displayTitle, 'Plan');
    expect(
      note.copyWith(attachments: [attachment('a', AttachmentKind.image)]).displayTitle,
      'Attachments',
    );
    expect(
      note
          .copyWith(
            body: 'text',
            attachments: [attachment('a', AttachmentKind.image)],
          )
          .displayTitle,
      'Untitled note',
    );
  });

  test('counts images and PDFs', () {
    final note = Note.create(t0).copyWith(attachments: [
      attachment('1', AttachmentKind.image),
      attachment('2', AttachmentKind.image),
      attachment('3', AttachmentKind.pdf),
    ]);
    expect(note.imageCount, 2);
    expect(note.pdfCount, 1);
  });

  test('survives a JSON round trip including attachments', () {
    final original = Note(
      id: 'n1',
      title: 'Title',
      body: 'Body\nwith lines',
      createdAt: t0,
      updatedAt: t0.add(const Duration(hours: 2)),
      attachments: [
        attachment('a', AttachmentKind.image, name: 'pic.png'),
        attachment('b', AttachmentKind.pdf, name: 'doc.pdf'),
      ],
    );

    final copy = Note.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(copy.id, 'n1');
    expect(copy.title, 'Title');
    expect(copy.body, 'Body\nwith lines');
    expect(copy.createdAt, t0);
    expect(copy.updatedAt, t0.add(const Duration(hours: 2)));
    expect(copy.attachments.map((a) => (a.id, a.name, a.kind, a.sizeBytes)), [
      ('a', 'pic.png', AttachmentKind.image, 1234),
      ('b', 'doc.pdf', AttachmentKind.pdf, 1234),
    ]);
  });

  test('a note saved without attachments still loads', () {
    final note = Note.fromJson({
      'id': 'n',
      'title': 't',
      'body': 'b',
      'createdAt': t0.toIso8601String(),
      'updatedAt': t0.toIso8601String(),
    });
    expect(note.attachments, isEmpty);
  });
}
