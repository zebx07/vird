import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/content_service.dart';
import '../services/did_you_know_service.dart';

class AppStateProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  bool _isFirstLaunch = true;
  int _streakDays = 0;
  int _totalDhikrCount = 0;
  DateTime? _lastActivityDate;

  AppStateProvider() {
    _loadAppState();
  }

  String get currentLanguage => _currentLanguage;
  bool get isFirstLaunch => _isFirstLaunch;
  int get streakDays => _streakDays;
  int get totalDhikrCount => _totalDhikrCount;
  DateTime? get lastActivityDate => _lastActivityDate;

  Future<void> _loadAppState() async {
    _currentLanguage = StorageService.getLanguage();
    // Load other state from storage
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  void updateStreak() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (_lastActivityDate == null) {
      _streakDays = 1;
    } else {
      final lastDate = DateTime(
        _lastActivityDate!.year,
        _lastActivityDate!.month,
        _lastActivityDate!.day,
      );

      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        // Consecutive day
        _streakDays++;
      } else if (difference > 1) {
        // Streak broken
        _streakDays = 1;
      }
      // If difference == 0, same day, don't change streak
    }

    _lastActivityDate = today;
    notifyListeners();

    // Save to storage
    _saveProgress();
  }

  void incrementDhikrCount(int count) {
    _totalDhikrCount += count;
    notifyListeners();
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    // Save progress to local storage and sync with server
    final progress = {
      'streak_days': _streakDays,
      'total_dhikr_count': _totalDhikrCount,
      'last_activity_date': _lastActivityDate?.toIso8601String(),
    };

    // Save locally and sync with Supabase if available
    // Implementation depends on your storage structure
  }

  void initializeDidYouKnow(BuildContext context) {
    DidYouKnowService.initialize(context);
  }

  void dispose() {
    DidYouKnowService.dispose();
    super.dispose();
  }
}
