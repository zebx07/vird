import 'dart:math';
import '../models/wisdom.dart';
import '../services/storage_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class WisdomService {
  static const String _tableName = 'wisdom';

  static Future<void> initWisdom() async {
    final db = await StorageService.getDatabase();

    // Check if wisdom table exists
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$_tableName'"
    );

    if (tables.isEmpty) {
      // Create wisdom table
      await db.execute('''
        CREATE TABLE $_tableName(
          id TEXT PRIMARY KEY,
          arabic_text TEXT NOT NULL,
          translation TEXT NOT NULL,
          source TEXT NOT NULL,
          category TEXT NOT NULL,
          is_shown INTEGER DEFAULT 0
        )
      ''');

      // Insert sample wisdom
      final sampleWisdom = Wisdom.getSampleWisdom();
      for (var wisdom in sampleWisdom) {
        await db.insert(_tableName, wisdom.toJson());
      }
    }
  }

  static Future<Wisdom?> getRandomWisdom() async {
    final db = await StorageService.getDatabase();

    // Get a random wisdom that hasn't been shown yet
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'is_shown = ?',
      whereArgs: [0],
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final wisdom = Wisdom.fromJson(maps.first);

      // Mark as shown
      await db.update(
        _tableName,
        {'is_shown': 1},
        where: 'id = ?',
        whereArgs: [wisdom.id],
      );

      return wisdom;
    }

    // If all wisdom has been shown, reset and get a new one
    await db.update(_tableName, {'is_shown': 0});

    final List<Map<String, dynamic>> resetMaps = await db.query(
      _tableName,
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (resetMaps.isNotEmpty) {
      final wisdom = Wisdom.fromJson(resetMaps.first);

      // Mark as shown
      await db.update(
        _tableName,
        {'is_shown': 1},
        where: 'id = ?',
        whereArgs: [wisdom.id],
      );

      return wisdom;
    }

    return null;
  }

  static Future<void> addWisdom(Wisdom wisdom) async {
    final db = await StorageService.getDatabase();
    await db.insert(_tableName, wisdom.toJson());
  }

  static Future<void> resetShownStatus() async {
    final db = await StorageService.getDatabase();
    await db.update(_tableName, {'is_shown': 0});
  }
}// TODO Implement this library.