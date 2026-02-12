import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';

// Events
abstract class DiaryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDiaryEntries extends DiaryEvent {}

class SyncDiaryEntries extends DiaryEvent {}

class AddDiaryEntry extends DiaryEvent {
  final DiaryEntry entry;
  AddDiaryEntry(this.entry);
  @override
  List<Object?> get props => [entry];
}

class UpdateDiaryEntry extends DiaryEvent {
  final DiaryEntry entry;
  UpdateDiaryEntry(this.entry);
  @override
  List<Object?> get props => [entry];
}

class DeleteDiaryEntry extends DiaryEvent {
  final String id;
  DeleteDiaryEntry(this.id);
  @override
  List<Object?> get props => [id];
}

// State
abstract class DiaryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DiaryInitial extends DiaryState {}

class DiaryLoading extends DiaryState {}

class DiaryLoaded extends DiaryState {
  final List<DiaryEntry> entries;
  DiaryLoaded(this.entries);
  @override
  List<Object?> get props => [entries];
}

class DiaryError extends DiaryState {
  final String message;
  DiaryError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final DiaryRepository repository;

  DiaryBloc({required this.repository}) : super(DiaryInitial()) {
    on<LoadDiaryEntries>((event, emit) async {
      emit(DiaryLoading());
      try {
        final entries = await repository.getEntries();
        emit(DiaryLoaded(entries));
      } catch (e) {
        emit(DiaryError('Failed to load entries: $e'));
      }
    });

    on<AddDiaryEntry>((event, emit) async {
      try {
        await repository.addEntry(event.entry);
        add(LoadDiaryEntries());
      } catch (e) {
        emit(DiaryError('Failed to add entry'));
      }
    });

    on<UpdateDiaryEntry>((event, emit) async {
      try {
        await repository.updateEntry(event.entry);
        add(LoadDiaryEntries());
      } catch (e) {
        emit(DiaryError('Failed to update entry'));
      }
    });

    on<DeleteDiaryEntry>((event, emit) async {
      try {
        await repository.deleteEntry(event.id);
        add(LoadDiaryEntries());
      } catch (e) {
        emit(DiaryError('Failed to delete entry'));
      }
    });

    on<SyncDiaryEntries>((event, emit) async {
      emit(DiaryLoading());
      try {
        await repository.sync();
        final entries = await repository.getEntries();
        emit(DiaryLoaded(entries));
      } catch (e) {
        emit(DiaryError('Sync failed: $e'));
      }
    });
  }
}
