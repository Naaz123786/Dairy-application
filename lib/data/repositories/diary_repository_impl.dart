import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/local_database.dart';
import '../models/diary_entry_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final LocalDatabase localDatabase;

  DiaryRepositoryImpl(this.localDatabase);

  @override
  Future<List<DiaryEntry>> getEntries() async {
    final entries = localDatabase.diaryBox.values.toList();
    entries.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    return entries.map(_mapModelToEntity).toList();
  }

  @override
  Future<void> addEntry(DiaryEntry entry) async {
    final model = _mapEntityToModel(entry);
    await localDatabase.diaryBox.put(entry.id, model);
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    final model = _mapEntityToModel(entry);
    await localDatabase.diaryBox.put(entry.id, model);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await localDatabase.diaryBox.delete(id);
  }

  @override
  Future<List<DiaryEntry>> searchEntries(String query) async {
    final entries = localDatabase.diaryBox.values.where((e) {
      return e.title.contains(query) || e.content.contains(query);
    }).toList();
    return entries.map(_mapModelToEntity).toList();
  }

  DiaryEntry _mapModelToEntity(DiaryEntryModel model) {
    return DiaryEntry(
      id: model.id,
      title: model.title,
      content: model.content,
      date: model.date,
      mood: model.mood,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      images: model.images,
    );
  }

  DiaryEntryModel _mapEntityToModel(DiaryEntry entity) {
    return DiaryEntryModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      date: entity.date,
      mood: entity.mood,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      images: entity.images,
    );
  }
}
