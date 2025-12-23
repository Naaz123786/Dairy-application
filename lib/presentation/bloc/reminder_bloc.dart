import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';

// Events
abstract class ReminderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {}

class AddReminder extends ReminderEvent {
  final Reminder reminder;
  AddReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class UpdateReminder extends ReminderEvent {
  final Reminder reminder;
  UpdateReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class DeleteReminder extends ReminderEvent {
  final String id;
  DeleteReminder(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class ReminderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<Reminder> reminders;
  ReminderLoaded(this.reminders);
  @override
  List<Object?> get props => [reminders];
}

class ReminderError extends ReminderState {
  final String message;
  ReminderError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository repository;

  ReminderBloc({required this.repository}) : super(ReminderInitial()) {
    on<LoadReminders>((event, emit) async {
      emit(ReminderLoading());
      try {
        final reminders = await repository.getReminders();
        emit(ReminderLoaded(reminders));
      } catch (e) {
        emit(ReminderError('Failed to load reminders: $e'));
      }
    });

    on<AddReminder>((event, emit) async {
      try {
        await repository.addReminder(event.reminder);
        add(LoadReminders());
      } catch (e) {
        emit(ReminderError('Failed to add reminder'));
      }
    });

    on<UpdateReminder>((event, emit) async {
      try {
        await repository.updateReminder(event.reminder);
        add(LoadReminders());
      } catch (e) {
        emit(ReminderError('Failed to update reminder'));
      }
    });

    on<DeleteReminder>((event, emit) async {
      try {
        await repository.deleteReminder(event.id);
        add(LoadReminders());
      } catch (e) {
        emit(ReminderError('Failed to delete reminder'));
      }
    });
  }
}
