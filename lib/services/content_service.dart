import 'dart:math';
import '../models/daily_content.dart';
import '../models/dhikr_session.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class ContentService {
  static Future<DailyContent> getDailyContent() async {
    final now = DateTime.now();
    String timeOfDay;

    if (now.hour >= 5 && now.hour < 12) {
      timeOfDay = 'morning';
    } else if (now.hour >= 12 && now.hour < 18) {
      timeOfDay = 'afternoon';
    } else if (now.hour >= 18 && now.hour < 22) {
      timeOfDay = 'evening';
    } else {
      timeOfDay = 'night';
    }

    // Try to get content for the current time of day
    DailyContent? content = await StorageService.getDailyContentForTime(
        timeOfDay);

    // If no content found, get any content
    if (content == null) {
      final allContent = await _getAllDailyContent();
      if (allContent.isNotEmpty) {
        content = allContent[Random().nextInt(allContent.length)];
      } else {
        // Fallback content if database is empty
        content = DailyContent(
          id: 'default',
          type: 'ayah',
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful',
          source: 'Quran 1:1',
          timeOfDay: timeOfDay,
        );
      }
    }

    return content;
  }

  static Future<List<DailyContent>> _getAllDailyContent() async {
    final db = await StorageService.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('daily_content');
    return List.generate(maps.length, (i) => DailyContent.fromJson(maps[i]));
  }

  static Future<void> syncContentFromServer() async {
    if (!SupabaseService.isAvailable) return;

    try {
      // Fetch new daily content
      final newContent = await SupabaseService.fetchNewDailyContent();

      // Save to local database
      final db = await StorageService.getDatabase();
      for (var content in newContent) {
        // Check if content already exists
        final existing = await db.query(
          'daily_content',
          where: 'id = ?',
          whereArgs: [content.id],
        );

        if (existing.isEmpty) {
          await db.insert('daily_content', content.toJson());
        }
      }
    } catch (e) {
      print('Error syncing content: $e');
    }
  }

  static Future<List<DhikrTemplate>> getDhikrForCategory(
      String category) async {
    final allDhikr = DhikrTemplate.getDefaultDhikr();
    return allDhikr.where((d) => d.category == category).toList();
  }

  static Future<List<DhikrTemplate>> getRecommendedDhikr() async {
    final allDhikr = DhikrTemplate.getDefaultDhikr();

    // Get user's recent sessions
    final recentSessions = await StorageService.getDhikrHistory();

    if (recentSessions.isEmpty) {
      // If no history, return default recommendations
      return allDhikr.take(3).toList();
    }

    // Find dhikr that user hasn't done recently
    final recentDhikrTexts = recentSessions.map((s) => s.dhikrText).toSet();
    final recommendations = allDhikr
        .where((d) => !recentDhikrTexts.contains(d.arabicText))
        .take(3)
        .toList();

    // If all dhikr have been done recently, return some random ones
    if (recommendations.isEmpty) {
      allDhikr.shuffle();
      return allDhikr.take(3).toList();
    }

    return recommendations;
  }
}
