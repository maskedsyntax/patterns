class JournalEntry {
  final int? id;
  final String date;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    this.id,
    required this.date,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'date': date,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      date: map['date'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

enum OcdType { obsession, compulsion }

class OcdEntry {
  final int? id;
  final OcdType type;
  final DateTime datetime;
  final String content; // Thought or Urge
  final int distressLevel;
  final String response;
  final String? actionTaken; // Only for compulsion
  final DateTime createdAt;

  OcdEntry({
    this.id,
    required this.type,
    required this.datetime,
    required this.content,
    required this.distressLevel,
    required this.response,
    this.actionTaken,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'type': type.index,
      'datetime': datetime.toIso8601String(),
      'content': content,
      'distress_level': distressLevel,
      'response': response,
      'action_taken': actionTaken,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory OcdEntry.fromMap(Map<String, dynamic> map) {
    return OcdEntry(
      id: map['id'],
      type: OcdType.values[map['type']],
      datetime: DateTime.parse(map['datetime']),
      content: map['content'],
      distressLevel: map['distress_level'],
      response: map['response'],
      actionTaken: map['action_taken'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
