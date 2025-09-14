class Note {
  String id;
  String title;
  String body; // plain fallback or plain text representation
  DateTime updatedAt;
  String format; // 'plain' or 'quill'
  Map<String, dynamic>? quillDelta; // stored delta when format == 'quill'

  Note({
    required this.id,
    required this.title,
    required this.body,
    this.format = 'plain',
    this.quillDelta,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    format: (json['format'] as String?) ?? 'plain',
    quillDelta: json['quillDelta'] as Map<String, dynamic>?,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'format': format,
    'quillDelta': quillDelta,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
