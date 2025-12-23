import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/local_database.dart';
import '../models/reminder_model.dart';
import '../../core/services/notification_service.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final LocalDatabase localDatabase;
  final NotificationService notificationService;

  ReminderRepositoryImpl(this.localDatabase, this.notificationService);

  @override
  Future<List<Reminder>> getReminders() async {
    final models = localDatabase.remindersBox.values.toList();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<void> addReminder(Reminder reminder) async {
    final model = _mapEntityToModel(reminder);
    await localDatabase.remindersBox.put(reminder.id, model);

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
    } else if (reminder.recurrenceType == 'Yearly') {
      await notificationService.scheduleBirthdayNotification(
        id: notificationId,
        name: reminder.title,
        birthdayDate: reminder.scheduledTime,
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
    // TODO: Cancel notification if possible (requires tracking IDs)
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
