import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Schedule daily dhikr reminders
  static Future<void> scheduleDailyReminders() async {
    await _scheduleNotification(
      id: 1,
      title: 'Morning Dhikr',
      body: 'Start your day with remembrance of Allah',
      hour: 7,
      minute: 0,
    );

    await _scheduleNotification(
      id: 2,
      title: 'Evening Dhikr',
      body: 'Take a moment for evening remembrance',
      hour: 18,
      minute: 0,
    );

    await _scheduleNotification(
      id: 3,
      title: 'Night Reflection',
      body: 'End your day with gratitude and reflection',
      hour: 21,
      minute: 30,
    );
  }

  // Schedule Friday Surah Kahf reminder
  static Future<void> scheduleFridayReminder() async {
    await _scheduleWeeklyNotification(
      id: 4,
      title: 'Surah Al-Kahf',
      body: 'Remember to read Surah Al-Kahf today',
      weekday: DateTime.friday,
      hour: 9,
      minute: 0,
    );
  }

  // Schedule nightly Surah Mulk reminder
  static Future<void> scheduleNightlyMulkReminder() async {
    await _scheduleNotification(
      id: 5,
      title: 'Surah Al-Mulk',
      body: 'Read Surah Al-Mulk before sleep for protection',
      hour: 22,
      minute: 0,
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Islamic Reminders',
          channelDescription: 'Daily notifications for Islamic practices',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeekday(weekday, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_reminders',
          'Weekly Islamic Reminders',
          channelDescription: 'Weekly notifications for Islamic practices',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> showDidYouKnowNotification(String wisdom) async {
    await _notifications.show(
      999,
      'Did You Know?',
      wisdom,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'wisdom',
          'Islamic Wisdom',
          channelDescription: 'Notifications with Islamic wisdom',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}// TODO Implement this library.