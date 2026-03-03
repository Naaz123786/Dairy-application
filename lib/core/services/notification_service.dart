import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, Colors;
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../domain/entities/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelReminders = 'reminders';
  static const String _channelDaily = _channelReminders;
  static const String _channelExam = _channelReminders;
  static const String _channelBirthdays = _channelReminders;

  /// Exam countdown reminder times: 12 AM, 6 AM, 6 PM
  static const int _examCountdownMidnightHour = 0;
  static const int _examCountdownMorningHour = 6;
  static const int _examCountdownEveningHour = 18;
  static const int _examCountdownCancelRange = 400;

  /// Initial notification channels. Must have at least one (plugin requirement).
  static List<NotificationChannel> get _initialChannels => [
        NotificationChannel(
          channelKey: _channelReminders,
          channelName: 'General Reminders',
          channelDescription: 'Routine & reminder notifications',
          defaultColor: const Color(0xFF00BCD4),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
        ),
      ];

  Future<void> init() async {
    if (kIsWeb) return;
    final channels = _initialChannels;
    assert(channels.isNotEmpty, 'Plugin requires at least one channel');
    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      channels,
      debug: kDebugMode,
    );
  }

  /// slot: 0 = 12 AM, 1 = 6 AM, 2 = 6 PM
  int _examCountdownId(String examId, int dayIndex, int slot) {
    final base = (examId.hashCode & 0x3FFFFFFF) * 100;
    return base + dayIndex * 3 + slot;
  }

  Future<String> _getTimeZone() async {
    try {
      return await AwesomeNotifications().getLocalTimeZoneIdentifier();
    } catch (_) {
      return 'Asia/Kolkata';
    }
  }

  Future<void> scheduleExamCountdownReminders(Reminder exam) async {
    if (kIsWeb) return;
    try {
      final tz = await _getTimeZone();
      final examDate = DateTime(exam.scheduledTime.year, exam.scheduledTime.month,
          exam.scheduledTime.day);
      final today =
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      if (examDate.isBefore(today)) return;

      final daysLeft = examDate.difference(today).inDays;

      final times = [
        _examCountdownMidnightHour, // 12 AM
        _examCountdownMorningHour,  // 6 AM
        _examCountdownEveningHour,  // 6 PM
      ];

      for (int dayIndex = 0; dayIndex < daysLeft; dayIndex++) {
        final date = today.add(Duration(days: dayIndex));
        final daysRemaining = daysLeft - dayIndex;
        final body = daysRemaining == 1
            ? 'Tomorrow is your exam: ${exam.title}'
            : '$daysRemaining days left – ${exam.title}';

        for (int slot = 0; slot < times.length; slot++) {
          final at = DateTime(
              date.year, date.month, date.day, times[slot], 0);
          if (at.isAfter(DateTime.now())) {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: _examCountdownId(exam.id, dayIndex, slot),
                channelKey: _channelExam,
                title: 'Exam reminder 📚',
                body: body,
                category: NotificationCategory.Reminder,
                wakeUpScreen: true,
              ),
              schedule: NotificationCalendar(
                year: at.year,
                month: at.month,
                day: at.day,
                hour: at.hour,
                minute: at.minute,
                second: 0,
                timeZone: tz,
                allowWhileIdle: true,
                preciseAlarm: true,
                repeats: false,
              ),
            );
          }
        }
      }

      // Exam day: 12 AM, 6 AM, 6 PM reminders
      for (int slot = 0; slot < times.length; slot++) {
        final at = DateTime(examDate.year, examDate.month, examDate.day,
            times[slot], 0);
        if (at.isAfter(DateTime.now())) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: _examCountdownId(exam.id, daysLeft, slot),
              channelKey: _channelExam,
              title: 'Exam today 📚',
              body: 'Today is your exam: ${exam.title}',
              category: NotificationCategory.Reminder,
              wakeUpScreen: true,
            ),
            schedule: NotificationCalendar(
              year: at.year,
              month: at.month,
              day: at.day,
              hour: at.hour,
              minute: at.minute,
              second: 0,
              timeZone: tz,
              allowWhileIdle: true,
              preciseAlarm: true,
              repeats: false,
            ),
          );
        }
      }

      debugPrint(
          'Exam countdown scheduled for "${exam.title}" at 12 AM, 6 AM, 6 PM ($daysLeft days + exam day)');
    } catch (e) {
      debugPrint('scheduleExamCountdownReminders error: $e');
    }
  }

  Future<void> cancelExamCountdownReminders(String examId) async {
    for (int dayIndex = 0; dayIndex < _examCountdownCancelRange; dayIndex++) {
      for (int slot = 0; slot < 3; slot++) {
        await AwesomeNotifications()
            .cancel(_examCountdownId(examId, dayIndex, slot));
      }
    }
    debugPrint('Exam countdown cancelled for $examId');
  }

  static const int _dailyReminderId = 0;
  static const int _dailyReminderHour = 21;
  static const int _dailyReminderMinute = 0;

  Future<void> scheduleDailyReminder() async {
    if (kIsWeb) return;
    try {
      final tz = await _getTimeZone();
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _dailyReminderId,
          channelKey: _channelDaily,
          title: 'Time to write! ✍️',
          body: "Don't forget to capture your thoughts in your diary today.",
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: _dailyReminderHour,
          minute: _dailyReminderMinute,
          second: 0,
          millisecond: 0,
          repeats: true,
          allowWhileIdle: true,
          preciseAlarm: true,
          timeZone: tz,
        ),
      );
      debugPrint('Daily diary reminder scheduled at $_dailyReminderHour:00');
    } catch (e) {
      debugPrint('scheduleDailyReminder error: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> scheduleRoutineDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    try {
      final tz = await _getTimeZone();
      final safeId = id & 0x7FFFFFFF;
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: safeId,
          channelKey: _channelReminders,
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          allowWhileIdle: true,
          preciseAlarm: true,
          timeZone: tz,
        ),
      );
      debugPrint(
          'Routine scheduled daily at $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('scheduleRoutineDaily error: $e');
    }
  }

  Future<void> scheduleAtTime({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (kIsWeb) return;
    try {
      if (scheduledTime.isBefore(DateTime.now())) return;
      final safeId = id & 0x7FFFFFFF;
      final tz = await _getTimeZone();
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: safeId,
          channelKey: _channelReminders,
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          year: scheduledTime.year,
          month: scheduledTime.month,
          day: scheduledTime.day,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
          second: scheduledTime.second,
          timeZone: tz,
          allowWhileIdle: true,
          preciseAlarm: true,
          repeats: false,
        ),
      );
      debugPrint('Reminder scheduled at $scheduledTime');
    } catch (e) {
      debugPrint('scheduleAtTime error: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id & 0x7FFFFFFF);
  }

  Future<void> scheduleBirthdayNotification({
    required int id,
    required String name,
    required DateTime birthdayDate,
    bool isYearly = true,
  }) async {
    if (kIsWeb) return;
    try {
      final tz = await _getTimeZone();
      final now = DateTime.now();
      int year = now.year;
      final month = birthdayDate.month;
      final day = birthdayDate.day;

      var bdMidnight = DateTime(year, month, day, 0, 0);
      var bdMorning = DateTime(year, month, day, 6, 0);
      if (bdMidnight.isBefore(now)) {
        year++;
        bdMidnight = DateTime(year, month, day, 0, 0);
        bdMorning = DateTime(year, month, day, 6, 0);
      }

      final title = 'Birthday: $name 🎂';
      final body = 'Wish $name a happy birthday today!';
      final safeId = id & 0x7FFFFFFF;

      if (bdMidnight.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: safeId,
            channelKey: _channelBirthdays,
            title: title,
            body: body,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
          ),
          schedule: NotificationCalendar(
            year: bdMidnight.year,
            month: bdMidnight.month,
            day: bdMidnight.day,
            hour: 0,
            minute: 0,
            second: 0,
            timeZone: tz,
            allowWhileIdle: true,
            preciseAlarm: true,
            repeats: false,
          ),
        );
      }
      if (bdMorning.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: safeId + 1,
            channelKey: _channelBirthdays,
            title: title,
            body: body,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
          ),
          schedule: NotificationCalendar(
            year: bdMorning.year,
            month: bdMorning.month,
            day: bdMorning.day,
            hour: 6,
            minute: 0,
            second: 0,
            timeZone: tz,
            allowWhileIdle: true,
            preciseAlarm: true,
            repeats: false,
          ),
        );
      }
      debugPrint('Birthday scheduled for $name at 12 AM & 6 AM');
    } catch (e) {
      debugPrint('scheduleBirthdayNotification error: $e');
    }
  }

  Future<void> cancelBirthdayNotifications(int id) async {
    await AwesomeNotifications().cancel(id & 0x7FFFFFFF);
    await AwesomeNotifications().cancel((id & 0x7FFFFFFF) + 1);
  }

  Future<void> cancelReminder() async {
    await AwesomeNotifications().cancel(_dailyReminderId);
    debugPrint('Daily reminder cancelled');
  }
}
