enum AttachmentKind { image, pdf }

/// A file attached to a note. The bytes live in the user's attachment folder
/// (see `AttachmentStorage`); this object only describes them.
class Attachment {
  const Attachment({
    required this.id,
    required this.name,
    required this.storedName,
    required this.kind,
    required this.sizeBytes,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      name: json['name'] as String,
      storedName: json['stored'] as String,
      kind: AttachmentKind.values.byName(json['kind'] as String),
      sizeBytes: json['size'] as int,
    );
  }

  final String id;

  /// File name shown to the user (the original name).
  final String name;

  /// File name inside the attachment folder (unique).
  final String storedName;

  final AttachmentKind kind;
  final int sizeBytes;

  bool get isImage => kind == AttachmentKind.image;
  bool get isPdf => kind == AttachmentKind.pdf;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'stored': storedName,
        'kind': kind.name,
        'size': sizeBytes,
      };

  @override
  bool operator ==(Object other) =>
      other is Attachment && other.id == id && other.storedName == storedName;

  @override
  int get hashCode => Object.hash(id, storedName);
}
