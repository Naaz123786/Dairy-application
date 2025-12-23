import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 1)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime scheduledTime;

  @HiveField(3)
  final bool isRecurring;

  @HiveField(4)
  final String recurrenceType; // 'Daily', 'Weekly', 'Monthly', 'None'

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final String category;

  ReminderModel({
    required this.id,
    required this.title,
    required this.scheduledTime,
    this.isRecurring = false,
    this.recurrenceType = 'None',
    this.isCompleted = false,
    this.category = 'calendar',
  });
}
