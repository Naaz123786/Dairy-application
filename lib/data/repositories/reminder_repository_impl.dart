import 'package:flutter/material.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/local_database.dart';
import '../datasources/firestore_database.dart';
import '../models/reminder_model.dart';
import '../../core/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final LocalDatabase localDatabase;
  final FirestoreDatabase firestoreDatabase;
  final NotificationService notificationService;

  ReminderRepositoryImpl(
    this.localDatabase,
    this.firestoreDatabase,
    this.notificationService,
  );

  @override
  Future<List<Reminder>> getReminders() async {
    // If logged in, fetch from Firestore to ensure sync
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final remoteModels = await firestoreDatabase.getReminders();
        for (var model in remoteModels) {
          await localDatabase.remindersBox.put(model.id, model);
        }
      } catch (e) {
        debugPrint('Reminder Sync Error: $e');
      }
    }

    final now = DateTime.now();
    final List<String> toDelete = [];

    for (var key in localDatabase.remindersBox.keys) {
      final model = localDatabase.remindersBox.get(key);
      if (model == null) continue;

      final isPastBy24h = now.difference(model.scheduledTime).inHours >= 24;

      // Non-recurring reminders (routine, etc.): remove 24 hours after scheduled time
      if (!model.isRecurring && isPastBy24h) {
        toDelete.add(model.id);
        continue;
      }

      // Birthday that does NOT repeat every year: remove 24 hours after birthday date
      final isNonYearlyBirthday = model.category == 'birthday' &&
          (!model.isRecurring || model.recurrenceType != 'Yearly');
      if (isNonYearlyBirthday && isPastBy24h) {
        toDelete.add(model.id);
      }
    }

    // Perform deletion
    for (var id in toDelete) {
      await deleteReminder(id);
    }

    final models = localDatabase.remindersBox.values.toList();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<void> addReminder(Reminder reminder) async {
    final model = _mapEntityToModel(reminder);

    // Save locally
    await localDatabase.remindersBox.put(reminder.id, model);

    // Sync to Firestore if logged in
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await firestoreDatabase.addReminder(model);
      } catch (e) {
        // Handle error or queue for later sync
      }
    }

    // Schedule notifications (don't fail the add if notifications fail)
    try {
      final notificationId = reminder.id.hashCode;
      if (reminder.category == 'routine') {
        await notificationService.scheduleRoutineDaily(
          id: notificationId,
          title: 'Routine: ${reminder.title}',
          body: 'Time for your task!',
          hour: reminder.scheduledTime.hour,
          minute: reminder.scheduledTime.minute,
        );
      } else if (reminder.category == 'exam') {
        await notificationService.cancelExamCountdownReminders(reminder.id);
        await notificationService.scheduleExamCountdownReminders(reminder);
        await notificationService.scheduleAtTime(
          id: notificationId,
          title: 'Exam: ${reminder.title}',
          body: 'Your exam is starting now.',
          scheduledTime: reminder.scheduledTime,
        );
      } else if (reminder.category == 'birthday') {
        await notificationService.scheduleBirthdayNotification(
          id: notificationId,
          name: reminder.title,
          birthdayDate: reminder.scheduledTime,
          isYearly: reminder.isRecurring,
        );
      } else if (reminder.category == 'calendar' || reminder.category.isEmpty) {
        await notificationService.scheduleAtTime(
          id: notificationId,
          title: 'Reminder: ${reminder.title}',
          body: 'Time for your reminder!',
          scheduledTime: reminder.scheduledTime,
        );
      } else {
        await notificationService.scheduleAtTime(
          id: notificationId,
          title: 'Reminder: ${reminder.title}',
          body: 'You have a reminder now!',
          scheduledTime: reminder.scheduledTime,
        );
      }
    } catch (e) {
      debugPrint('Reminder notification schedule failed: $e');
    }
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    // For local DB, add/put with same ID acts as update
    await addReminder(reminder);
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      await notificationService.cancelExamCountdownReminders(id);
    } catch (_) {}
    try {
      await notificationService.cancelBirthdayNotifications(id.hashCode);
    } catch (_) {}
    try {
      await notificationService.cancelNotification(id.hashCode);
    } catch (_) {}
    await localDatabase.remindersBox.delete(id);
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await firestoreDatabase.deleteReminder(id);
      } catch (e) {
        debugPrint('Firestore deleteReminder error: $e');
      }
    }
  }

  @override
  Future<void> sync() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 1. Fetch remote data
    final remoteModels = await firestoreDatabase.getReminders();

    // 2. Fetch local data
    final localModels = localDatabase.remindersBox.values.toList();

    // 3. Upload local missing items to remote
    for (var local in localModels) {
      bool existsRemotely = remoteModels.any((remote) => remote.id == local.id);
      if (!existsRemotely) {
        await firestoreDatabase.addReminder(local);
      }
    }

    // 4. Download remote items to local
    for (var remote in remoteModels) {
      await localDatabase.remindersBox.put(remote.id, remote);
    }

    // 5. Update last sync time
    await localDatabase.setLastSyncTime(DateTime.now());
  }

  Reminder _mapModelToEntity(ReminderModel model) {
    return Reminder(
      id: model.id,
      title: model.title,
      scheduledTime: model.scheduledTime,
      isRecurring: model.isRecurring,
      recurrenceType: model.recurrenceType,
      isCompleted: model.isCompleted,
      category: model.category,
    );
  }

  ReminderModel _mapEntityToModel(Reminder entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      scheduledTime: entity.scheduledTime,
      isRecurring: entity.isRecurring,
      recurrenceType: entity.recurrenceType,
      isCompleted: entity.isCompleted,
      category: entity.category,
    );
  }
}
