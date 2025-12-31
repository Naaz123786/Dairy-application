import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/firestore_database.dart';
import '../models/diary_entry_model.dart';

class DiaryRepositoryFirestoreImpl implements DiaryRepository {
  final FirestoreDatabase firestoreDatabase;

  DiaryRepositoryFirestoreImpl(this.firestoreDatabase);

  @override
  Future<List<DiaryEntry>> getEntries() async {
    final models = await firestoreDatabase.getEntries();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<void> addEntry(DiaryEntry entry) async {
    final model = _mapEntityToModel(entry);
    await firestoreDatabase.addEntry(model);
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    final model = _mapEntityToModel(entry);
    await firestoreDatabase.updateEntry(model);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await firestoreDatabase.deleteEntry(id);
  }

  @override
  Future<List<DiaryEntry>> searchEntries(String query) async {
    // Firestore search is limited. Ideally use Algolia or client-side filtering.
    // implementing client-side filtering here for simplicity as the dataset might not be huge per user.
    final allEntries = await getEntries();
    return allEntries.where((e) {
      return e.title.toLowerCase().contains(query.toLowerCase()) ||
          e.content.toLowerCase().contains(query.toLowerCase());
    }).toList();
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
    );
  }
}
