import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reflection.dart';
import '../models/daily_content.dart';
import '../models/wisdom.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
      );

      _client = Supabase.instance.client;
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize Supabase: $e');
      // Continue without Supabase
    }
  }

  static bool get isAvailable => _isInitialized && _client != null;

  static Future<List<DuaWallPost>> getDuaWallPosts() async {
    if (!isAvailable) return [];

    try {
      final response = await _client!
          .from('dua_wall_posts')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((data) => DuaWallPost(
        id: data['id'],
        content: data['content'],
        mood: data['mood'],
        prayerCount: data['prayer_count'] ?? 0,
        createdAt: DateTime.parse(data['created_at']),
        isOwnPost: false,
      ))
          .toList();
    } catch (e) {
      print('Error fetching Du\'a Wall posts: $e');
      return [];
    }
  }

  static Future<void> shareDuaWallPost(Reflection reflection) async {
    if (!isAvailable) return;

    try {
      await _client!.from('dua_wall_posts').insert({
        'id': reflection.id,
        'content': reflection.content,
        'mood': reflection.mood,
        'prayer_count': 0,
        'created_at': reflection.createdAt.toIso8601String(),
      });
    } catch (e) {
      print('Error sharing Du\'a Wall post: $e');
      throw e;
    }
  }

  static Future<void> prayForPost(String postId) async {
    if (!isAvailable) return;

    try {
      // Get current prayer count
      final response = await _client!
          .from('dua_wall_posts')
          .select('prayer_count')
          .eq('id', postId)
          .single();

      final currentCount = response['prayer_count'] ?? 0;

      // Increment prayer count
      await _client!
          .from('dua_wall_posts')
          .update({'prayer_count': currentCount + 1})
          .eq('id', postId);
    } catch (e) {
      print('Error praying for post: $e');
      throw e;
    }
  }

  static Future<List<DailyContent>> fetchNewDailyContent() async {
    if (!isAvailable) return [];

    try {
      final response = await _client!
          .from('daily_content')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((data) => DailyContent.fromJson(data))
          .toList();
    } catch (e) {
      print('Error fetching daily content: $e');
      return [];
    }
  }

  static Future<List<Wisdom>> fetchNewWisdom() async {
    if (!isAvailable) return [];

    try {
      final response = await _client!
          .from('wisdom')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((data) => Wisdom.fromJson(data))
          .toList();
    } catch (e) {
      print('Error fetching wisdom: $e');
      return [];
    }
  }

  static Future<void> syncUserProgress(Map<String, dynamic> progress) async {
    if (!isAvailable) return;

    try {
      final deviceId = Uuid().v4(); // Generate a unique device ID

      await _client!
          .from('user_progress')
          .upsert({
        'device_id': deviceId,
        ...progress,
        'last_synced': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error syncing user progress: $e');
    }
  }
}// TODO Implement this library.