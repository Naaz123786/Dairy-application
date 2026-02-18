import 'package:flutter/material.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/firestore_database.dart';
import '../datasources/local_database.dart';
import '../models/diary_entry_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaryRepositoryFirestoreImpl implements DiaryRepository {
  final FirestoreDatabase firestoreDatabase;
  final LocalDatabase localDatabase;

  DiaryRepositoryFirestoreImpl(this.firestoreDatabase, this.localDatabase);

  @override
  Future<List<DiaryEntry>> getEntries() async {
    // Sync from Firestore if logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final remoteModels = await firestoreDatabase.getEntries();
        // Clear local cache for this sync to ensure deleted remote entries are removed locally
        // Alternatively, if we want offline support, we'd do a more complex merge.
        // For now, let's ensure remote data is present locally.
        for (var model in remoteModels) {
          await localDatabase.diaryBox.put(model.id, model);
        }
      } catch (e) {
        debugPrint('Diary Sync Error: $e');
      }
    }

    final models = localDatabase.diaryBox.values.toList();
    // Sort by date descending
    models.sort((a, b) => b.date.compareTo(a.date));
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<void> addEntry(DiaryEntry entry) async {
    final model = _mapEntityToModel(entry);
    // Save locally
    await localDatabase.diaryBox.put(entry.id, model);

    // Sync to Firestore if logged in
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await firestoreDatabase.addEntry(model);
      } catch (e) {
        // Handle sync error
      }
    }
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    await addEntry(entry);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await localDatabase.diaryBox.delete(id);
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await firestoreDatabase.deleteEntry(id);
      } catch (e) {
        // Handle sync error
      }
    }
  }

  @override
  Future<List<DiaryEntry>> searchEntries(String query) async {
    final allEntries = await getEntries();
    return allEntries.where((e) {
      return e.title.toLowerCase().contains(query.toLowerCase()) ||
          e.content.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Future<void> sync() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 1. Fetch remote data
    final remoteModels = await firestoreDatabase.getEntries();

    // 2. Fetch local data
    final localModels = localDatabase.diaryBox.values.toList();

    // 3. Upload local missing items to remote
    for (var local in localModels) {
      bool existsRemotely = remoteModels.any((remote) => remote.id == local.id);
      if (!existsRemotely) {
        await firestoreDatabase.addEntry(local);
      }
    }

    // 4. Download remote missing/updated items to local
    for (var remote in remoteModels) {
      await localDatabase.diaryBox.put(remote.id, remote);
    }

    // 5. Update last sync time
    await localDatabase.setLastSyncTime(DateTime.now());
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
