import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wisdom.dart';
import '../services/wisdom_service.dart';
import '../widgets/did_you_know_popup.dart';

enum WisdomTrigger {
  idle,
  session,
  achievement,
  timeOfDay,
  manual,
  contextual,
}

enum WisdomFrequency {
  low,      // Every 15-20 minutes
  medium,   // Every 8-12 minutes
  high,     // Every 3-5 minutes
}

class WisdomSettings {
  final WisdomFrequency frequency;
  final bool enableIdleTrigger;
  final bool enableSessionTrigger;
  final bool enableTimeBasedTrigger;
  final bool enableContextualTrigger;
  final bool enableHapticFeedback;
  final bool enableSoundEffects;

  const WisdomSettings({
    this.frequency = WisdomFrequency.medium,
    this.enableIdleTrigger = true,
    this.enableSessionTrigger = true,
    this.enableTimeBasedTrigger = true,
    this.enableContextualTrigger = true,
    this.enableHapticFeedback = true,
    this.enableSoundEffects = false,
  });
}

class WisdomSession {
  final DateTime startTime;
  final List<String> shownWisdomIds;
  final Map<WisdomTrigger, int> triggerCounts;
  int userInteractions;

  WisdomSession({
    required this.startTime,
    List<String>? shownWisdomIds,
    Map<WisdomTrigger, int>? triggerCounts,
    this.userInteractions = 0,
  }) : shownWisdomIds = shownWisdomIds ?? [],
        triggerCounts = triggerCounts ?? {};

  Duration get sessionDuration => DateTime.now().difference(startTime);
  bool get isLongSession => sessionDuration.inMinutes > 30;
  double get engagementScore => userInteractions / (sessionDuration.inMinutes + 1);
}

class DidYouKnowService {
  static Timer? _idleTimer;
  static Timer? _sessionTimer;
  static Timer? _timeBasedTimer;
  static bool _isPopupShowing = false;
  static bool _isInitialized = false;

  static WisdomSettings _settings = WisdomSettings();
  static WisdomSession? _currentSession;
  static DateTime? _lastWisdomShown;
  static String? _currentContext;
  static final List<String> _recentWisdomIds = [];
  static final Set<String> _bookmarkedWisdomIds = {};

  // Adaptive timing based on user behavior
  static int _baseIdleTimeSeconds = 180; // 3 minutes
  static int _baseSessionTimeSeconds = 600; // 10 minutes
  static final int _maxRecentWisdom = 10;

  /// Initialize the wisdom service with optional settings
  static Future<void> initialize(
      BuildContext context, {
        WisdomSettings? settings,
      }) async {
    if (_isInitialized) return;

    _settings = settings ?? WisdomSettings();
    _currentSession = WisdomSession(startTime: DateTime.now());

    // Initialize wisdom database
    await WisdomService.initWisdom();

    // Start various timers based on settings
    if (_settings.enableSessionTrigger) {
      _startSessionTimer(context);
    }

    if (_settings.enableIdleTrigger) {
      _resetIdleTimer(context);
    }

    if (_settings.enableTimeBasedTrigger) {
      _startTimeBasedTimer(context);
    }

    _isInitialized = true;

    debugPrint('DidYouKnowService initialized with settings: ${_settings.frequency}');
  }

  /// Update service settings
  static void updateSettings(WisdomSettings newSettings) {
    _settings = newSettings;
    _adaptTimingToFrequency();
  }

  /// Set current context for contextual wisdom
  static void setContext(String context) {
    _currentContext = context;
  }

  /// Start session timer with adaptive timing
  static void _startSessionTimer(BuildContext context) {
    _sessionTimer?.cancel();

    final adaptiveTime = _getAdaptiveSessionTime();
    _sessionTimer = Timer(Duration(seconds: adaptiveTime), () {
      _showWisdom(context, trigger: WisdomTrigger.session);
    });
  }

  /// Reset idle timer with adaptive timing
  static void _resetIdleTimer(BuildContext context) {
    _idleTimer?.cancel();

    final adaptiveTime = _getAdaptiveIdleTime();
    _idleTimer = Timer(Duration(seconds: adaptiveTime), () {
      _showWisdom(context, trigger: WisdomTrigger.idle);
    });
  }

  /// Start time-based timer for specific times of day
  static void _startTimeBasedTimer(BuildContext context) {
    _timeBasedTimer?.cancel();

    final now = DateTime.now();
    final nextTrigger = _getNextTimeBasedTrigger(now);

    if (nextTrigger != null) {
      final duration = nextTrigger.difference(now);
      _timeBasedTimer = Timer(duration, () {
        _showWisdom(context, trigger: WisdomTrigger.timeOfDay);
        _startTimeBasedTimer(context); // Schedule next
      });
    }
  }

  /// Get next time-based trigger (prayer times, morning, evening, etc.)
  static DateTime? _getNextTimeBasedTrigger(DateTime now) {
    final triggers = [
      DateTime(now.year, now.month, now.day, 6, 0), // Fajr time
      DateTime(now.year, now.month, now.day, 12, 30), // Dhuhr time
      DateTime(now.year, now.month, now.day, 15, 30), // Asr time
      DateTime(now.year, now.month, now.day, 18, 0), // Maghrib time
      DateTime(now.year, now.month, now.day, 20, 0), // Isha time
      DateTime(now.year, now.month, now.day, 22, 0), // Night reflection
    ];

    for (final trigger in triggers) {
      if (trigger.isAfter(now)) {
        return trigger;
      }
    }

    // If no trigger today, return first trigger tomorrow
    final tomorrow = now.add(Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6, 0);
  }

  /// Record user activity and reset idle timer
  static void userActivity(BuildContext context) {
    if (!_isInitialized) return;

    _currentSession?.userInteractions++;

    if (_settings.enableIdleTrigger) {
      _resetIdleTimer(context);
    }
  }

  /// Show wisdom with enhanced logic
  static Future<void> _showWisdom(
      BuildContext context, {
        required WisdomTrigger trigger,
        String? specificWisdomId,
      }) async {
    if (_isPopupShowing || !context.mounted) return;

    // Check if enough time has passed since last wisdom
    if (_lastWisdomShown != null) {
      final timeSinceLastWisdom = DateTime.now().difference(_lastWisdomShown!);
      if (timeSinceLastWisdom.inMinutes < _getMinimumInterval()) {
        return;
      }
    }

    Wisdom? wisdom;

    if (specificWisdomId != null) {
      // Try to get specific wisdom by ID (if WisdomService supports it)
      wisdom = await WisdomService.getRandomWisdom();
    } else {
      wisdom = await _getContextualWisdom(trigger);
    }

    if (wisdom != null && context.mounted) {
      await _displayWisdom(context, wisdom, trigger);
    }
  }

  /// Get contextual wisdom based on trigger and current context
  static Future<Wisdom?> _getContextualWisdom(WisdomTrigger trigger) async {
    // Get random wisdom from the service
    final wisdom = await WisdomService.getRandomWisdom();

    // Check if this wisdom was recently shown
    if (wisdom != null && _recentWisdomIds.contains(wisdom.id)) {
      // Try to get another one (simple approach)
      final alternativeWisdom = await WisdomService.getRandomWisdom();
      if (alternativeWisdom != null && !_recentWisdomIds.contains(alternativeWisdom.id)) {
        return alternativeWisdom;
      }
    }

    return wisdom;
  }

  /// Display wisdom with enhanced popup
  static Future<void> _displayWisdom(
      BuildContext context,
      Wisdom wisdom,
      WisdomTrigger trigger,
      ) async {
    _isPopupShowing = true;
    _lastWisdomShown = DateTime.now();

    // Add to recent wisdom list
    _recentWisdomIds.add(wisdom.id);
    if (_recentWisdomIds.length > _maxRecentWisdom) {
      _recentWisdomIds.removeAt(0);
    }

    // Update session tracking
    _currentSession?.shownWisdomIds.add(wisdom.id);
    _currentSession?.triggerCounts[trigger] =
        (_currentSession?.triggerCounts[trigger] ?? 0) + 1;

    // Haptic feedback if enabled
    if (_settings.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DidYouKnowPopup(
        wisdom: wisdom,
        onClose: () {
          Navigator.of(context).pop();
          _onWisdomClosed(context);
        },
        onShare: () => _onWisdomShared(wisdom),
        onBookmark: () => _onWisdomBookmarked(wisdom),
        onNext: () => _onNextWisdom(context),
      ),
    );
  }

  /// Handle wisdom popup closure
  static void _onWisdomClosed(BuildContext context) {
    _isPopupShowing = false;

    // Restart timers
    if (_settings.enableIdleTrigger) {
      _resetIdleTimer(context);
    }
    if (_settings.enableSessionTrigger) {
      _startSessionTimer(context);
    }

    // Adapt timing based on user engagement
    _adaptTimingToEngagement();
  }

  /// Handle wisdom sharing
  static void _onWisdomShared(Wisdom wisdom) {
    // Track sharing analytics
    debugPrint('Wisdom shared: ${wisdom.id}');
    // Could integrate with analytics service or sharing functionality
  }

  /// Handle wisdom bookmarking (local storage)
  static void _onWisdomBookmarked(Wisdom wisdom) {
    // Add to local bookmarks set
    if (_bookmarkedWisdomIds.contains(wisdom.id)) {
      _bookmarkedWisdomIds.remove(wisdom.id);
      debugPrint('Wisdom unbookmarked: ${wisdom.id}');
    } else {
      _bookmarkedWisdomIds.add(wisdom.id);
      debugPrint('Wisdom bookmarked: ${wisdom.id}');
    }
    // Could save to SharedPreferences or local database
  }

  /// Check if wisdom is bookmarked
  static bool isWisdomBookmarked(String wisdomId) {
    return _bookmarkedWisdomIds.contains(wisdomId);
  }

  /// Get all bookmarked wisdom IDs
  static Set<String> getBookmarkedWisdomIds() {
    return Set.from(_bookmarkedWisdomIds);
  }

  /// Handle next wisdom request
  static void _onNextWisdom(BuildContext context) {
    Navigator.of(context).pop();
    _isPopupShowing = false;

    // Show another wisdom immediately
    Future.delayed(Duration(milliseconds: 300), () {
      _showWisdom(context, trigger: WisdomTrigger.manual);
    });
  }

  /// Public methods for manual wisdom display
  static Future<void> showRandomWisdom(BuildContext context) async {
    await _showWisdom(context, trigger: WisdomTrigger.manual);
  }

  static Future<void> showWisdomAfterAchievement(
      BuildContext context,
      String achievementType,
      ) async {
    setContext(achievementType);
    await _showWisdom(context, trigger: WisdomTrigger.achievement);
  }

  /// Legacy method for backward compatibility
  static Future<void> showWisdomAfterSession(BuildContext context) async {
    await _showWisdom(context, trigger: WisdomTrigger.session);
  }

  /// Adaptive timing methods
  static void _adaptTimingToFrequency() {
    switch (_settings.frequency) {
      case WisdomFrequency.low:
        _baseIdleTimeSeconds = 900; // 15 minutes
        _baseSessionTimeSeconds = 1200; // 20 minutes
        break;
      case WisdomFrequency.medium:
        _baseIdleTimeSeconds = 480; // 8 minutes
        _baseSessionTimeSeconds = 720; // 12 minutes
        break;
      case WisdomFrequency.high:
        _baseIdleTimeSeconds = 180; // 3 minutes
        _baseSessionTimeSeconds = 300; // 5 minutes
        break;
    }
  }

  static void _adaptTimingToEngagement() {
    if (_currentSession == null) return;

    final engagementScore = _currentSession!.engagementScore;

    // Adjust timing based on engagement
    if (engagementScore > 0.5) {
      // High engagement - show wisdom more frequently
      _baseIdleTimeSeconds = (_baseIdleTimeSeconds * 0.8).round();
      _baseSessionTimeSeconds = (_baseSessionTimeSeconds * 0.8).round();
    } else if (engagementScore < 0.2) {
      // Low engagement - show wisdom less frequently
      _baseIdleTimeSeconds = (_baseIdleTimeSeconds * 1.2).round();
      _baseSessionTimeSeconds = (_baseSessionTimeSeconds * 1.2).round();
    }
  }

  static int _getAdaptiveIdleTime() {
    final baseTime = _baseIdleTimeSeconds;
    final randomVariation = math.Random().nextInt(60) - 30; // ±30 seconds
    return (baseTime + randomVariation).clamp(60, 1800); // 1 min to 30 min
  }

  static int _getAdaptiveSessionTime() {
    final baseTime = _baseSessionTimeSeconds;
    final randomVariation = math.Random().nextInt(120) - 60; // ±1 minute
    return (baseTime + randomVariation).clamp(180, 3600); // 3 min to 1 hour
  }

  static int _getMinimumInterval() {
    switch (_settings.frequency) {
      case WisdomFrequency.low:
        return 10; // 10 minutes minimum
      case WisdomFrequency.medium:
        return 5; // 5 minutes minimum
      case WisdomFrequency.high:
        return 2; // 2 minutes minimum
    }
  }

  /// Helper methods
  static String _getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  /// Session management
  static WisdomSession? getCurrentSession() => _currentSession;

  static void endSession() {
    _currentSession = null;
    _recentWisdomIds.clear();
  }

  static void startNewSession() {
    _currentSession = WisdomSession(startTime: DateTime.now());
  }

  /// Cleanup
  static void dispose() {
    _idleTimer?.cancel();
    _sessionTimer?.cancel();
    _timeBasedTimer?.cancel();
    _isInitialized = false;
    _currentSession = null;
    _recentWisdomIds.clear();

    debugPrint('DidYouKnowService disposed');
  }

  /// Debug and analytics
  static Map<String, dynamic> getAnalytics() {
    return {
      'isInitialized': _isInitialized,
      'currentSession': _currentSession?.startTime.toIso8601String(),
      'sessionDuration': _currentSession?.sessionDuration.inMinutes,
      'wisdomShownCount': _currentSession?.shownWisdomIds.length ?? 0,
      'engagementScore': _currentSession?.engagementScore ?? 0.0,
      'triggerCounts': _currentSession?.triggerCounts.map((k, v) => MapEntry(k.toString(), v)) ?? {},
      'recentWisdomCount': _recentWisdomIds.length,
      'bookmarkedWisdomCount': _bookmarkedWisdomIds.length,
      'lastWisdomShown': _lastWisdomShown?.toIso8601String(),
      'currentContext': _currentContext,
      'settings': {
        'frequency': _settings.frequency.toString(),
        'enabledTriggers': {
          'idle': _settings.enableIdleTrigger,
          'session': _settings.enableSessionTrigger,
          'timeBased': _settings.enableTimeBasedTrigger,
          'contextual': _settings.enableContextualTrigger,
        },
      },
    };
  }
}