import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final String id;
  final String title;
  final DateTime scheduledTime;
  final bool isRecurring;
  final String recurrenceType; // 'Daily', 'Weekly', 'Yearly', 'None'
  final bool isCompleted;
  final String category; // 'calendar', 'routine', 'exam'

  const Reminder({
    required this.id,
    required this.title,
    required this.scheduledTime,
    this.isRecurring = false,
    this.recurrenceType = 'None',
    this.isCompleted = false,
    this.category = 'calendar',
  });

  @override
  List<Object?> get props => [
    id,
    title,
    scheduledTime,
    isRecurring,
    recurrenceType,
    isCompleted,
    category,
  ];
}
