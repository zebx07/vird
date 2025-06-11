import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/mood.dart';
import '../models/daily_content.dart';
import '../models/dhikr_session.dart';
import '../models/reflection.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static late Database _database;
  static final Map<String, dynamic> _cache = {};
  static const int _databaseVersion = 2;
  static const String _databaseName = 'islamic_vird.db';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _database = await _initDatabase();
      await _loadCacheFromPrefs();
      print('StorageService initialized successfully');
    } catch (e) {
      print('Error initializing StorageService: $e');
      rethrow;
    }
  }

  static Future<Database> getDatabase() async {
    return _database;
  }

  static Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) async {
          // Enable foreign key constraints
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertInitialData(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
      await db.execute('''
        ALTER TABLE user_progress ADD COLUMN favorite_dhikr TEXT
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_settings(
          id TEXT PRIMARY KEY,
          key TEXT UNIQUE NOT NULL,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS backup_metadata(
          id TEXT PRIMARY KEY,
          backup_date TEXT NOT NULL,
          file_path TEXT NOT NULL,
          size_bytes INTEGER NOT NULL,
          checksum TEXT NOT NULL
        )
      ''');
    }
  }

  static Future<void> _createTables(Database db) async {
    // Mood entries table
    await db.execute('''
      CREATE TABLE mood_entries(
        id TEXT PRIMARY KEY,
        mood_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Dhikr sessions table
    await db.execute('''
      CREATE TABLE dhikr_sessions(
        id TEXT PRIMARY KEY,
        dhikr_text TEXT NOT NULL,
        target_count INTEGER NOT NULL,
        actual_count INTEGER NOT NULL,
        duration_minutes INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        mood_before TEXT,
        mood_after TEXT,
        location TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Reflections table
    await db.execute('''
      CREATE TABLE reflections(
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        mood TEXT,
        is_anonymous BOOLEAN DEFAULT 0,
        created_at TEXT NOT NULL,
        session_id TEXT,
        tags TEXT,
        word_count INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (session_id) REFERENCES dhikr_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Daily content table
    await db.execute('''
      CREATE TABLE daily_content(
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        arabic_text TEXT NOT NULL,
        translation TEXT NOT NULL,
        transliteration TEXT,
        source TEXT NOT NULL,
        time_of_day TEXT NOT NULL,
        date_shown TEXT,
        category TEXT DEFAULT 'general',
        difficulty_level INTEGER DEFAULT 1,
        audio_url TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // User progress table
    await db.execute('''
      CREATE TABLE user_progress(
        id TEXT PRIMARY KEY,
        streak_days INTEGER DEFAULT 0,
        total_dhikr_count INTEGER DEFAULT 0,
        total_sessions INTEGER DEFAULT 0,
        last_activity_date TEXT,
        rewards_unlocked TEXT,
        level INTEGER DEFAULT 1,
        experience_points INTEGER DEFAULT 0,
        favorite_dhikr TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Dua wall posts table
    await db.execute('''
      CREATE TABLE dua_wall_posts(
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        mood TEXT,
        prayer_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        is_own_post BOOLEAN DEFAULT 0,
        is_reported BOOLEAN DEFAULT 0,
        tags TEXT,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE app_settings(
        id TEXT PRIMARY KEY,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Backup metadata table
    await db.execute('''
      CREATE TABLE backup_metadata(
        id TEXT PRIMARY KEY,
        backup_date TEXT NOT NULL,
        file_path TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        checksum TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_mood_entries_timestamp ON mood_entries(timestamp)');
    await db.execute('CREATE INDEX idx_dhikr_sessions_completed_at ON dhikr_sessions(completed_at)');
    await db.execute('CREATE INDEX idx_reflections_created_at ON reflections(created_at)');
    await db.execute('CREATE INDEX idx_daily_content_time_of_day ON daily_content(time_of_day)');
    await db.execute('CREATE INDEX idx_dua_wall_posts_created_at ON dua_wall_posts(created_at)');
  }

  static Future<void> _insertInitialData(Database db) async {
    // Insert comprehensive daily content
    final dailyContents = [
      // Morning content
      {
        'id': 'morning_1',
        'type': 'ayah',
        'arabic_text': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
        'translation': 'And whoever fears Allah - He will make for him a way out',
        'transliteration': 'Wa man yattaqi Allaha yaj\'al lahu makhrajan',
        'source': 'Quran 65:2',
        'time_of_day': 'morning',
        'category': 'hope',
        'difficulty_level': 1
      },
      {
        'id': 'morning_2',
        'type': 'dhikr',
        'arabic_text': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
        'translation': 'We have reached the morning and at this very time unto Allah belongs all sovereignty',
        'transliteration': 'Asbahna wa asbahal-mulku lillah',
        'source': 'Muslim',
        'time_of_day': 'morning',
        'category': 'morning_dhikr',
        'difficulty_level': 1
      },
      // Evening content
      {
        'id': 'evening_1',
        'type': 'dhikr',
        'arabic_text': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        'translation': 'Glory is to Allah and praise is to Him',
        'transliteration': 'Subhan Allahi wa bihamdihi',
        'source': 'Sahih Bukhari',
        'time_of_day': 'evening',
        'category': 'praise',
        'difficulty_level': 1
      },
      {
        'id': 'evening_2',
        'type': 'ayah',
        'arabic_text': 'وَهُوَ الَّذِي يُنَزِّلُ الْغَيْثَ مِن بَعْدِ مَا قَنَطُوا',
        'translation': 'And it is He who sends down the rain after they had despaired',
        'transliteration': 'Wa huwa alladhi yunazzilu al-ghaytha min ba\'di ma qanatoo',
        'source': 'Quran 42:28',
        'time_of_day': 'evening',
        'category': 'mercy',
        'difficulty_level': 2
      },
      // Night content
      {
        'id': 'night_1',
        'type': 'dhikr',
        'arabic_text': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
        'translation': 'We have reached the evening and at this very time unto Allah belongs all sovereignty',
        'transliteration': 'Amsayna wa amsal-mulku lillah',
        'source': 'Muslim',
        'time_of_day': 'night',
        'category': 'evening_dhikr',
        'difficulty_level': 1
      }
    ];

    for (var content in dailyContents) {
      await db.insert('daily_content', content, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Insert initial user progress
    await db.insert('user_progress', {
      'id': 'user_1',
      'streak_days': 0,
      'total_dhikr_count': 0,
      'total_sessions': 0,
      'level': 1,
      'experience_points': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // Enhanced cache management
  static Future<void> _loadCacheFromPrefs() async {
    final cacheData = _prefs.getString('app_cache');
    if (cacheData != null) {
      try {
        _cache.addAll(json.decode(cacheData));
      } catch (e) {
        print('Error loading cache: $e');
      }
    }
  }

  static Future<void> _saveCacheToPrefs() async {
    try {
      await _prefs.setString('app_cache', json.encode(_cache));
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  static void _setCacheValue(String key, dynamic value) {
    _cache[key] = value;
    _saveCacheToPrefs();
  }

  static T? _getCacheValue<T>(String key) {
    return _cache[key] as T?;
  }

  // Enhanced mood operations
  static Future<void> saveMoodEntry(MoodEntry entry) async {
    try {
      await _database.insert('mood_entries', entry.toJson());
      _cache.remove('mood_history'); // Invalidate cache
      await _updateUserProgress();
    } catch (e) {
      print('Error saving mood entry: $e');
      rethrow;
    }
  }

  static Future<List<MoodEntry>> getMoodHistory({int? limit, DateTime? since}) async {
    try {
      final cacheKey = 'mood_history_${limit ?? 'all'}_${since?.toIso8601String() ?? 'all'}';
      final cached = _getCacheValue<List<MoodEntry>>(cacheKey);
      if (cached != null) return cached;

      String query = 'SELECT * FROM mood_entries';
      List<dynamic> args = [];

      if (since != null) {
        query += ' WHERE timestamp >= ?';
        args.add(since.toIso8601String());
      }

      query += ' ORDER BY timestamp DESC';

      if (limit != null) {
        query += ' LIMIT ?';
        args.add(limit);
      }

      final List<Map<String, dynamic>> maps = await _database.rawQuery(query, args);
      final result = List.generate(maps.length, (i) => MoodEntry.fromJson(maps[i]));

      _setCacheValue(cacheKey, result);
      return result;
    } catch (e) {
      print('Error getting mood history: $e');
      return [];
    }
  }

  // Enhanced dhikr session operations
  static Future<void> saveDhikrSession(DhikrSession session) async {
    try {
      await _database.insert('dhikr_sessions', session.toJson());
      _cache.remove('dhikr_history'); // Invalidate cache
      await _updateUserProgress(
        dhikrCount: session.actualCount,
        sessionCompleted: true,
      );
    } catch (e) {
      print('Error saving dhikr session: $e');
      rethrow;
    }
  }

  static Future<List<DhikrSession>> getDhikrHistory({int? limit, DateTime? since}) async {
    try {
      final cacheKey = 'dhikr_history_${limit ?? 'all'}_${since?.toIso8601String() ?? 'all'}';
      final cached = _getCacheValue<List<DhikrSession>>(cacheKey);
      if (cached != null) return cached;

      String query = 'SELECT * FROM dhikr_sessions';
      List<dynamic> args = [];

      if (since != null) {
        query += ' WHERE completed_at >= ?';
        args.add(since.toIso8601String());
      }

      query += ' ORDER BY completed_at DESC';

      if (limit != null) {
        query += ' LIMIT ?';
        args.add(limit);
      }

      final List<Map<String, dynamic>> maps = await _database.rawQuery(query, args);
      final result = List.generate(maps.length, (i) => DhikrSession.fromJson(maps[i]));

      _setCacheValue(cacheKey, result);
      return result;
    } catch (e) {
      print('Error getting dhikr history: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getDhikrStatistics() async {
    try {
      final cached = _getCacheValue<Map<String, dynamic>>('dhikr_stats');
      if (cached != null) return cached;

      final result = await _database.rawQuery('''
        SELECT 
          COUNT(*) as total_sessions,
          SUM(actual_count) as total_dhikr,
          AVG(actual_count) as avg_per_session,
          SUM(duration_minutes) as total_minutes,
          MAX(actual_count) as best_session
        FROM dhikr_sessions
      ''');

      final stats = result.first;
      _setCacheValue('dhikr_stats', stats);
      return stats;
    } catch (e) {
      print('Error getting dhikr statistics: $e');
      return {};
    }
  }

  // Enhanced reflection operations
  static Future<void> saveReflection(Reflection reflection) async {
    try {
      final reflectionData = reflection.toJson();
      reflectionData['word_count'] = reflection.content.split(' ').length;

      await _database.insert('reflections', reflectionData);
      _cache.remove('reflections'); // Invalidate cache
    } catch (e) {
      print('Error saving reflection: $e');
      rethrow;
    }
  }

  static Future<List<Reflection>> getReflections({bool? isAnonymous, int? limit}) async {
    try {
      String query = 'SELECT * FROM reflections';
      List<dynamic> args = [];

      if (isAnonymous != null) {
        query += ' WHERE is_anonymous = ?';
        args.add(isAnonymous ? 1 : 0);
      }

      query += ' ORDER BY created_at DESC';

      if (limit != null) {
        query += ' LIMIT ?';
        args.add(limit);
      }

      final List<Map<String, dynamic>> maps = await _database.rawQuery(query, args);
      return List.generate(maps.length, (i) => Reflection.fromJson(maps[i]));
    } catch (e) {
      print('Error getting reflections: $e');
      return [];
    }
  }

  // Enhanced daily content operations
  static Future<DailyContent?> getDailyContentForTime(String timeOfDay, {String? category}) async {
    try {
      final cacheKey = 'daily_content_${timeOfDay}_${category ?? 'any'}';
      final cached = _getCacheValue<DailyContent>(cacheKey);
      if (cached != null) return cached;

      String query = 'SELECT * FROM daily_content WHERE time_of_day = ?';
      List<dynamic> args = [timeOfDay];

      if (category != null) {
        query += ' AND category = ?';
        args.add(category);
      }

      query += ' ORDER BY RANDOM() LIMIT 1';

      final List<Map<String, dynamic>> maps = await _database.rawQuery(query, args);

      if (maps.isNotEmpty) {
        final content = DailyContent.fromJson(maps.first);
        _setCacheValue(cacheKey, content);
        return content;
      }
      return null;
    } catch (e) {
      print('Error getting daily content: $e');
      return null;
    }
  }

  static Future<void> markContentAsShown(String contentId) async {
    try {
      await _database.update(
        'daily_content',
        {'date_shown': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [contentId],
      );
    } catch (e) {
      print('Error marking content as shown: $e');
    }
  }

  // User progress operations
  static Future<void> _updateUserProgress({
    int dhikrCount = 0,
    bool sessionCompleted = false,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final progress = await getUserProgress();
      final lastActivity = progress['last_activity_date'] != null
          ? DateTime.parse(progress['last_activity_date'])
          : null;

      int newStreak = progress['streak_days'] ?? 0;
      if (lastActivity == null || lastActivity.isBefore(today)) {
        if (lastActivity != null && today.difference(lastActivity).inDays == 1) {
          newStreak++;
        } else if (lastActivity != null && today.difference(lastActivity).inDays > 1) {
          newStreak = 1;
        } else {
          newStreak = 1;
        }
      }

      final newTotalDhikr = (progress['total_dhikr_count'] ?? 0) + dhikrCount;
      final newTotalSessions = (progress['total_sessions'] ?? 0) + (sessionCompleted ? 1 : 0);
      final newXP = (progress['experience_points'] ?? 0) + (dhikrCount * 2) + (sessionCompleted ? 50 : 0);
      final newLevel = (newXP ~/ 1000) + 1;

      await _database.update(
        'user_progress',
        {
          'streak_days': newStreak,
          'total_dhikr_count': newTotalDhikr,
          'total_sessions': newTotalSessions,
          'experience_points': newXP,
          'level': newLevel,
          'last_activity_date': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: ['user_1'],
      );

      _cache.remove('user_progress'); // Invalidate cache
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final cached = _getCacheValue<Map<String, dynamic>>('user_progress');
      if (cached != null) return cached;

      final List<Map<String, dynamic>> maps = await _database.query(
        'user_progress',
        where: 'id = ?',
        whereArgs: ['user_1'],
      );

      if (maps.isNotEmpty) {
        final progress = maps.first;
        _setCacheValue('user_progress', progress);
        return progress;
      }

      return {
        'streak_days': 0,
        'total_dhikr_count': 0,
        'total_sessions': 0,
        'level': 1,
        'experience_points': 0,
      };
    } catch (e) {
      print('Error getting user progress: $e');
      return {};
    }
  }

  // Enhanced user preferences with caching
  static Future<void> setLanguage(String languageCode) async {
    await _prefs.setString('language', languageCode);
    _setCacheValue('language', languageCode);
  }

  static String getLanguage() {
    final cached = _getCacheValue<String>('language');
    if (cached != null) return cached;

    final value = _prefs.getString('language') ?? 'en';
    _setCacheValue('language', value);
    return value;
  }

  static Future<void> setThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
    _setCacheValue('theme_mode', mode);
  }

  static String getThemeMode() {
    final cached = _getCacheValue<String>('theme_mode');
    if (cached != null) return cached;

    final value = _prefs.getString('theme_mode') ?? 'system';
    _setCacheValue('theme_mode', value);
    return value;
  }

  static Future<void> setAccentColor(String color) async {
    await _prefs.setString('accent_color', color);
    _setCacheValue('accent_color', color);
  }

  static String? getAccentColor() {
    final cached = _getCacheValue<String>('accent_color');
    if (cached != null) return cached;

    final value = _prefs.getString('accent_color');
    if (value != null) _setCacheValue('accent_color', value);
    return value;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
    _setCacheValue('notifications_enabled', enabled);
  }

  static bool getNotificationsEnabled() {
    final cached = _getCacheValue<bool>('notifications_enabled');
    if (cached != null) return cached;

    final value = _prefs.getBool('notifications_enabled') ?? true;
    _setCacheValue('notifications_enabled', value);
    return value;
  }

  // Backup and restore functionality
  static Future<String> createBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('${backupDir.path}/backup_$timestamp.json');

      final data = {
        'version': _databaseVersion,
        'created_at': DateTime.now().toIso8601String(),
        'mood_entries': await _getAllTableData('mood_entries'),
        'dhikr_sessions': await _getAllTableData('dhikr_sessions'),
        'reflections': await _getAllTableData('reflections'),
        'user_progress': await _getAllTableData('user_progress'),
        'preferences': {
          'language': getLanguage(),
          'theme_mode': getThemeMode(),
          'accent_color': getAccentColor(),
          'notifications_enabled': getNotificationsEnabled(),
        }
      };

      await backupFile.writeAsString(json.encode(data));

      // Save backup metadata
      await _database.insert('backup_metadata', {
        'id': 'backup_$timestamp',
        'backup_date': DateTime.now().toIso8601String(),
        'file_path': backupFile.path,
        'size_bytes': await backupFile.length(),
        'checksum': data.hashCode.toString(),
      });

      return backupFile.path;
    } catch (e) {
      print('Error creating backup: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> _getAllTableData(String tableName) async {
    return await _database.query(tableName);
  }

  static Future<void> restoreFromBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final content = await file.readAsString();
      final data = json.decode(content);

      // Clear existing data
      await _clearAllData();

      // Restore data
      for (final entry in data['mood_entries']) {
        await _database.insert('mood_entries', entry);
      }
      for (final entry in data['dhikr_sessions']) {
        await _database.insert('dhikr_sessions', entry);
      }
      for (final entry in data['reflections']) {
        await _database.insert('reflections', entry);
      }
      for (final entry in data['user_progress']) {
        await _database.insert('user_progress', entry);
      }

      // Restore preferences
      final prefs = data['preferences'];
      await setLanguage(prefs['language'] ?? 'en');
      await setThemeMode(prefs['theme_mode'] ?? 'system');
      if (prefs['accent_color'] != null) {
        await setAccentColor(prefs['accent_color']);
      }
      await setNotificationsEnabled(prefs['notifications_enabled'] ?? true);

      // Clear cache
      _cache.clear();
      await _saveCacheToPrefs();
    } catch (e) {
      print('Error restoring backup: $e');
      rethrow;
    }
  }

  static Future<void> _clearAllData() async {
    await _database.delete('mood_entries');
    await _database.delete('dhikr_sessions');
    await _database.delete('reflections');
    await _database.delete('user_progress');
    await _database.delete('dua_wall_posts');
  }

  // Data export functionality
  static Future<String> exportDataAsJson() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportFile = File('${directory.path}/islamic_vird_export_${DateTime.now().millisecondsSinceEpoch}.json');

      final data = {
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'user_progress': await getUserProgress(),
        'dhikr_sessions': await getDhikrHistory(),
        'reflections': await getReflections(),
        'mood_history': await getMoodHistory(),
        'statistics': await getDhikrStatistics(),
      };

      await exportFile.writeAsString(json.encode(data, toEncodable: (obj) {
        if (obj is DateTime) return obj.toIso8601String();
        return obj.toString();
      }));

      return exportFile.path;
    } catch (e) {
      print('Error exporting data: $e');
      rethrow;
    }
  }

  // Database maintenance
  static Future<void> optimizeDatabase() async {
    try {
      await _database.execute('VACUUM');
      await _database.execute('ANALYZE');
      print('Database optimized successfully');
    } catch (e) {
      print('Error optimizing database: $e');
    }
  }

  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final dbPath = join(await getDatabasesPath(), _databaseName);
      final file = File(dbPath);
      final size = await file.length();

      final tables = await _database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'"
      );

      final info = {
        'database_path': dbPath,
        'size_bytes': size,
        'size_mb': (size / (1024 * 1024)).toStringAsFixed(2),
        'version': _databaseVersion,
        'tables': tables.map((t) => t['name']).toList(),
      };

      return info;
    } catch (e) {
      print('Error getting database info: $e');
      return {};
    }
  }

  // Cleanup old data
  static Future<void> cleanupOldData({int daysToKeep = 365}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final cutoffString = cutoffDate.toIso8601String();

      await _database.delete(
        'mood_entries',
        where: 'timestamp < ?',
        whereArgs: [cutoffString],
      );

      await _database.delete(
        'backup_metadata',
        where: 'backup_date < ?',
        whereArgs: [cutoffString],
      );

      _cache.clear();
      await _saveCacheToPrefs();

      print('Old data cleaned up successfully');
    } catch (e) {
      print('Error cleaning up old data: $e');
    }
  }

  // Reset all data
  static Future<void> resetAllData() async {
    try {
      await _clearAllData();
      await _prefs.clear();
      _cache.clear();

      // Reinitialize with default data
      await _insertInitialData(_database);

      print('All data reset successfully');
    } catch (e) {
      print('Error resetting data: $e');
      rethrow;
    }
  }
}