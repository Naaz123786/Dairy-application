import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diary_entry_model.dart';
import '../models/reminder_model.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _getUsersCollection() {
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(_userId).collection('entries');
  }

  CollectionReference<Map<String, dynamic>> _getRemindersCollection() {
    if (_userId == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(_userId).collection('reminders');
  }

  // Diary Methods
  Future<List<DiaryEntryModel>> getEntries() async {
    if (_userId == null) return [];

    final snapshot =
        await _getUsersCollection().orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => DiaryEntryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addEntry(DiaryEntryModel entry) async {
    await _getUsersCollection().doc(entry.id).set(entry.toMap());
  }

  Future<void> updateEntry(DiaryEntryModel entry) async {
    await _getUsersCollection().doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    await _getUsersCollection().doc(id).delete();
  }

  // Reminder Methods
  Future<List<ReminderModel>> getReminders() async {
    if (_userId == null) return [];

    final snapshot = await _getRemindersCollection().get();

    return snapshot.docs
        .map((doc) => ReminderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _getRemindersCollection().doc(reminder.id).set(reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _getRemindersCollection().doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String id) async {
    await _getRemindersCollection().doc(id).delete();
  }
}
