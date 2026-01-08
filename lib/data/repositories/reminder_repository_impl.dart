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

    // Auto-cleanup: remove non-recurring reminders older than 24 hours
    for (var key in localDatabase.remindersBox.keys) {
      final model = localDatabase.remindersBox.get(key);
      if (model != null && !model.isRecurring) {
        if (now.difference(model.scheduledTime).inHours >= 24) {
          toDelete.add(model.id);
        }
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

    // Schedule Notification
    // We use hashcode of ID for notification ID (simple approach) or random int
    final notificationId = reminder.id.hashCode;

    if (reminder.category == 'routine') {
      await notificationService.scheduleNotification(
        id: notificationId,
        title: 'Routine: ${reminder.title}',
        body: 'Time for your task!',
        scheduledDate: reminder.scheduledTime,
      );
    } else if (reminder.category == 'exam') {
      await notificationService.scheduleNotification(
        id: notificationId,
        title: 'Exam Alert: ${reminder.title}',
        body: 'Your exam is coming up!',
        scheduledDate: reminder.scheduledTime,
      );
    } else if (reminder.category == 'birthday') {
      await notificationService.scheduleBirthdayNotification(
        id: notificationId,
        name: reminder.title,
        birthdayDate: reminder.scheduledTime,
        isYearly: reminder.isRecurring,
      );
    } else {
      await notificationService.scheduleNotification(
        id: notificationId,
        title: 'Reminder: ${reminder.title}',
        body: 'You have a reminder now!',
        scheduledDate: reminder.scheduledTime,
      );
    }
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    // For local DB, add/put with same ID acts as update
    await addReminder(reminder);
  }

  @override
  Future<void> deleteReminder(String id) async {
    await localDatabase.remindersBox.delete(id);
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await firestoreDatabase.deleteReminder(id);
      } catch (e) {
        // Handle sync error
      }
    }
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
