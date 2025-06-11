import 'package:flutter/material.dart';

class Mood {
  final String id;
  final String name;
  final String emoji;
  final Color color;

  Mood({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });
}

class MoodEntry {
  final String id;
  final String moodId;
  final DateTime timestamp;
  final String? note;

  MoodEntry({
    required this.id,
    required this.moodId,
    required this.timestamp,
    this.note,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      moodId: json['mood_id'],
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood_id': moodId,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}
