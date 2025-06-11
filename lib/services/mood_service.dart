import '../models/mood.dart';
import 'package:uuid/uuid.dart';
import 'storage_service.dart';

enum MoodPeriod {
  today,
  thisWeek,
  thisMonth,
  allTime,
}

class MoodStats {
  final int totalEntries;
  final double averageScore;
  final int streakDays;
  final Map<String, int> moodCounts;

  MoodStats({
    required this.totalEntries,
    required this.averageScore,
    required this.streakDays,
    required this.moodCounts,
  });
}

class MoodService {
  static final _uuid = Uuid();

  /// Record a mood entry with optional note
  static Future<void> recordMood(Mood mood, {String? note}) async {
    final entry = MoodEntry(
      id: _uuid.v4(),
      moodId: mood.id,
      timestamp: DateTime.now(),
      note: note,
    );

    await StorageService.saveMoodEntry(entry);
  }

  /// Get mood history with optional filtering
  static Future<List<MoodEntry>> getMoodHistory({
    MoodPeriod period = MoodPeriod.allTime,
  }) async {
    var entries = await StorageService.getMoodHistory();

    // Filter by period
    final now = DateTime.now();
    DateTime? startDate;

    switch (period) {
      case MoodPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case MoodPeriod.thisWeek:
        startDate = now.subtract(Duration(days: 7));
        break;
      case MoodPeriod.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case MoodPeriod.allTime:
        return entries;
    }

    if (startDate != null) {
      entries = entries.where((entry) =>
          entry.timestamp.isAfter(startDate!)).toList();
    }

    return entries;
  }

  /// Get basic mood statistics
  static Future<MoodStats> getMoodStats({
    MoodPeriod period = MoodPeriod.thisMonth,
  }) async {
    final entries = await getMoodHistory(period: period);

    if (entries.isEmpty) {
      return MoodStats(
        totalEntries: 0,
        averageScore: 0.0,
        streakDays: 0,
        moodCounts: {},
      );
    }

    // Count mood occurrences
    final moodCounts = <String, int>{};
    double totalScore = 0.0;

    for (final entry in entries) {
      moodCounts[entry.moodId] = (moodCounts[entry.moodId] ?? 0) + 1;
      // Assuming mood has a score property, otherwise use a default
      totalScore += 3.0; // Default score, adjust based on your Mood model
    }

    final averageScore = totalScore / entries.length;
    final streakDays = await _calculateStreak();

    return MoodStats(
      totalEntries: entries.length,
      averageScore: averageScore,
      streakDays: streakDays,
      moodCounts: moodCounts,
    );
  }

  /// Calculate current tracking streak
  static Future<int> _calculateStreak() async {
    final entries = await getMoodHistory();
    if (entries.isEmpty) return 0;

    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 30; i++) { // Check last 30 days
      final checkDate = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));

      final hasEntry = entries.any((entry) {
        final entryDate = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );
        return entryDate.isAtSameMomentAs(checkDate);
      });

      if (hasEntry) {
        streak++;
      } else if (i > 0) { // Don't break on first day if no entry today
        break;
      }
    }

    return streak;
  }

  /// Get most used moods
  static Future<List<String>> getMostUsedMoods({int limit = 5}) async {
    final entries = await getMoodHistory(period: MoodPeriod.thisMonth);
    final moodCounts = <String, int>{};

    for (final entry in entries) {
      moodCounts[entry.moodId] = (moodCounts[entry.moodId] ?? 0) + 1;
    }

    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedMoods
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if mood was recorded today
  static Future<bool> hasMoodToday() async {
    final todayEntries = await getMoodHistory(period: MoodPeriod.today);
    return todayEntries.isNotEmpty;
  }

  /// Get last mood entry
  static Future<MoodEntry?> getLastMoodEntry() async {
    final entries = await getMoodHistory();
    if (entries.isEmpty) return null;

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.first;
  }
}