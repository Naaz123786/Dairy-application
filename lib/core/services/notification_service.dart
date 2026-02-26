import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../domain/entities/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int _examCountdownMorningHour = 6;
  static const int _examCountdownEveningHour = 18;
  /// Max days to consider when cancelling (no schedule limit - all days until exam).
  static const int _examCountdownCancelRange = 400;

  Future<void> init() async {
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

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap if needed
      },
    );

    // Initialize timezone for scheduled notifications (non-web)
    if (!kIsWeb) {
      await _ensureTimezone();
    }
  }

  /// Ensures timezone is set so scheduled notifications fire at correct local time.
  Future<void> _ensureTimezone() async {
    try {
      tz_data.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Timezone set: $timeZoneName');
    } catch (e) {
      debugPrint('Timezone init error: $e, using Asia/Kolkata');
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (_) {}
    }
  }

  /// Unique notification id for exam countdown (morning/evening per day).
  int _examCountdownId(String examId, int dayIndex, int slot) {
    final base = (examId.hashCode & 0x3FFFFFFF) * 100;
    return base + dayIndex * 2 + slot;
  }

  Future<void> scheduleExamCountdownReminders(Reminder exam) async {
    if (kIsWeb) return;
    final examDate = DateTime(exam.scheduledTime.year, exam.scheduledTime.month,
        exam.scheduledTime.day);
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (examDate.isBefore(today)) return;

    final daysLeft = examDate.difference(today).inDays;
    // No limit: schedule every day from today until exam (3 months, 6 months, etc.)
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'exam_countdown',
        'Exam Countdown',
        channelDescription: 'Daily exam countdown reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);

    // Each day from today until the day before exam: morning 6 AM + evening 6 PM
    for (int dayIndex = 0; dayIndex < daysLeft; dayIndex++) {
      final date = today.add(Duration(days: dayIndex));
      final daysRemaining = daysLeft - dayIndex;
      final body = daysRemaining == 1
          ? 'Tomorrow is your exam: ${exam.title}'
          : '$daysRemaining days left – ${exam.title}';

      final morningAt = tz.TZDateTime(tz.local, date.year, date.month, date.day,
          _examCountdownMorningHour, 0);
      if (morningAt.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          _examCountdownId(exam.id, dayIndex, 0),
          'Exam reminder 📚',
          body,
          morningAt,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }

      final eveningAt = tz.TZDateTime(tz.local, date.year, date.month, date.day,
          _examCountdownEveningHour, 0);
      if (eveningAt.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          _examCountdownId(exam.id, dayIndex, 1),
          'Exam reminder 📚',
          body,
          eveningAt,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    // Exam day morning: "Today is your exam"
    final examDayMorning = tz.TZDateTime(
        tz.local,
        examDate.year,
        examDate.month,
        examDate.day,
        _examCountdownMorningHour,
        0);
    if (examDayMorning.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        _examCountdownId(exam.id, daysLeft, 0),
        'Exam today 📚',
        'Today is your exam: ${exam.title}',
        examDayMorning,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    debugPrint(
        'Exam countdown scheduled for "${exam.title}" ($daysLeft days + exam day morning)');
  }

  Future<void> cancelExamCountdownReminders(String examId) async {
    for (int dayIndex = 0; dayIndex < _examCountdownCancelRange; dayIndex++) {
      await _notificationsPlugin.cancel(_examCountdownId(examId, dayIndex, 0));
      await _notificationsPlugin.cancel(_examCountdownId(examId, dayIndex, 1));
    }
    debugPrint('Exam countdown cancelled for $examId');
  }

  /// Daily diary reminder: every day at 9 PM.
  static const int _dailyReminderId = 0;
  static const int _dailyReminderHour = 21; // 9 PM
  static const int _dailyReminderMinute = 0;

  Future<void> scheduleDailyReminder() async {
    if (kIsWeb) return;
    try {
      await _ensureTimezone();
      final now = tz.TZDateTime.now(tz.local);
      var at = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        _dailyReminderHour,
        _dailyReminderMinute,
      );
      if (at.isBefore(now) || at.isAtSameMomentAs(now)) {
        at = at.add(const Duration(days: 1));
      }
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily reminder to write in your diary',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _notificationsPlugin.zonedSchedule(
        _dailyReminderId,
        'Time to write! ✍️',
        "Don't forget to capture your thoughts in your diary today.",
        at,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Daily diary reminder scheduled at $_dailyReminderHour:00');
    } catch (e) {
      debugPrint('scheduleDailyReminder error: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  /// Schedules a daily routine notification at the same time every day.
  Future<void> scheduleRoutineDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    try {
      await _ensureTimezone();
      final now = tz.TZDateTime.now(tz.local);
      var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (at.isBefore(now) || at.isAtSameMomentAs(now)) {
        at = at.add(const Duration(days: 1));
      }
      final safeId = id & 0x7FFFFFFF;
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'General Reminders',
          channelDescription: 'Routine & reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _notificationsPlugin.zonedSchedule(
        safeId,
        title,
        body,
        at,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Routine scheduled daily at $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('scheduleRoutineDaily error: $e');
    }
  }

  /// Schedules a one-time notification at the exact date & time (for routines/reminders).
  Future<void> scheduleAtTime({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (kIsWeb) return;
    try {
      await _ensureTimezone();
      final at = tz.TZDateTime.from(scheduledTime, tz.local);
      if (at.isBefore(tz.TZDateTime.now(tz.local))) return;
      final safeId = id & 0x7FFFFFFF;
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'General Reminders',
          channelDescription: 'Routine & reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _notificationsPlugin.zonedSchedule(
        safeId,
        title,
        body,
        at,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Routine/reminder scheduled at $scheduledTime');
    } catch (e) {
      debugPrint('scheduleAtTime error: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id & 0x7FFFFFFF);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'General Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    debugPrint('Notification scheduled for $scheduledDate');
  }

  /// Schedules birthday wish: 12 AM (midnight) + 6 AM on the birthday date.
  Future<void> scheduleBirthdayNotification({
    required int id,
    required String name,
    required DateTime birthdayDate,
    bool isYearly = true,
  }) async {
    if (kIsWeb) return;
    try {
      await _ensureTimezone();
      final now = tz.TZDateTime.now(tz.local);
      final year = now.year;
      final month = birthdayDate.month;
      final day = birthdayDate.day;
      // This year's birthday: if already passed, use next year
      var bdMidnight = tz.TZDateTime(tz.local, year, month, day, 0, 0);
      var bdMorning = tz.TZDateTime(tz.local, year, month, day, 6, 0);
      if (bdMidnight.isBefore(now)) {
        bdMidnight = tz.TZDateTime(tz.local, year + 1, month, day, 0, 0);
        bdMorning = tz.TZDateTime(tz.local, year + 1, month, day, 6, 0);
      }
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'birthdays',
          'Birthday Reminders',
          channelDescription: 'Birthday wish reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      final safeId = id & 0x7FFFFFFF;
      final title = 'Birthday: $name 🎂';
      final body = 'Wish $name a happy birthday today!';
      if (bdMidnight.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          safeId,
          title,
          body,
          bdMidnight,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      if (bdMorning.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          safeId + 1,
          title,
          body,
          bdMorning,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      debugPrint('Birthday scheduled for $name at 12 AM & 6 AM');
    } catch (e) {
      debugPrint('scheduleBirthdayNotification error: $e');
    }
  }

  /// Cancel both birthday slots (12 AM and 6 AM) for a reminder id.
  Future<void> cancelBirthdayNotifications(int id) async {
    await _notificationsPlugin.cancel(id & 0x7FFFFFFF);
    await _notificationsPlugin.cancel((id & 0x7FFFFFFF) + 1);
  }

  Future<void> cancelReminder() async {
    await _notificationsPlugin.cancel(0);
    debugPrint('Daily reminder cancelled');
  }
}
