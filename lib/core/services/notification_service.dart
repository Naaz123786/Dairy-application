import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // FIXME: zonedSchedule API mismatch. Using simple notification for now to unblock.
    // await _notificationsPlugin.zonedSchedule(
    //   id,
    //   title,
    //   body,
    //   tz.TZDateTime.from(scheduledDate, tz.local),
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'reminders_channel',
    //       'Reminders',
    //       channelDescription: 'Channel for general reminders',
    //       importance: Importance.max,
    //       priority: Priority.high,
    //     ),
    //   ),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Channel for general reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleBirthdayNotification({
    required int id,
    required String name,
    required DateTime birthdayDate,
  }) async {
    final now = DateTime.now();
    DateTime scheduleDate = DateTime(
      now.year,
      birthdayDate.month,
      birthdayDate.day,
      0,
      0,
    );

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 365));
    }

    await scheduleNotification(
      id: id,
      title: "It's $name's Birthday! 🎉",
      body: "Wish them first!",
      scheduledDate: scheduleDate,
    );
  }
}
