class Reflection {
  final String id;
  final String content;
  final String? mood;
  final bool isAnonymous;
  final DateTime createdAt;
  final String? sessionId;

  Reflection({
    required this.id,
    required this.content,
    this.mood,
    this.isAnonymous = false,
    required this.createdAt,
    this.sessionId,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      id: json['id'],
      content: json['content'],
      mood: json['mood'],
      isAnonymous: json['is_anonymous'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      sessionId: json['session_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'mood': mood,
      'is_anonymous': isAnonymous ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'session_id': sessionId,
    };
  }
}

class DuaWallPost {
  final String id;
  final String content;
  final String? mood;
  final int prayerCount;
  final DateTime createdAt;
  final bool isOwnPost;

  DuaWallPost({
    required this.id,
    required this.content,
    this.mood,
    this.prayerCount = 0,
    required this.createdAt,
    this.isOwnPost = false,
  });

  factory DuaWallPost.fromJson(Map<String, dynamic> json) {
    return DuaWallPost(
      id: json['id'],
      content: json['content'],
      mood: json['mood'],
      prayerCount: json['prayer_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      isOwnPost: json['is_own_post'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'mood': mood,
      'prayer_count': prayerCount,
      'created_at': createdAt.toIso8601String(),
      'is_own_post': isOwnPost ? 1 : 0,
    };
  }
}// TODO Implement this library.