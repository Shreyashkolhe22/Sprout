import 'attachment.dart';

/// A note with optional image / PDF attachments. Immutable: edit with
/// [copyWith] and save through `NotesController`.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.attachments = const [],
  });

  factory Note.create(DateTime now) {
    return Note(
      id: now.microsecondsSinceEpoch.toString(),
      title: '',
      body: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      attachments: [
        for (final a in (json['attachments'] as List? ?? const []))
          Attachment.fromJson(a as Map<String, dynamic>),
      ],
    );
  }

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Attachment> attachments;

  /// Nothing worth saving: no title, no text and no attachments.
  bool get isBlank =>
      title.trim().isEmpty && body.trim().isEmpty && attachments.isEmpty;

  String get displayTitle {
    final t = title.trim();
    if (t.isNotEmpty) return t;
    return attachments.isNotEmpty && body.trim().isEmpty
        ? 'Attachments'
        : 'Untitled note';
  }

  int get imageCount => attachments.where((a) => a.isImage).length;
  int get pdfCount => attachments.where((a) => a.isPdf).length;

  Note copyWith({
    String? title,
    String? body,
    DateTime? updatedAt,
    List<Attachment>? attachments,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'attachments': [for (final a in attachments) a.toJson()],
      };
}
