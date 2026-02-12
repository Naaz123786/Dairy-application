import '../entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>> getEntries();
  Future<void> addEntry(DiaryEntry entry);
  Future<void> updateEntry(DiaryEntry entry);
  Future<void> deleteEntry(String id);
  Future<List<DiaryEntry>> searchEntries(String query);
  Future<void> sync();
}
