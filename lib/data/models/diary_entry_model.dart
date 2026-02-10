import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'diary_entry_model.g.dart';

@HiveType(typeId: 0)
class DiaryEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String mood; // 'Happy', 'Sad', etc.

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final List<String> images;

  DiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'mood': mood,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'images': images,
    };
  }

  factory DiaryEntryModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime getDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return DiaryEntryModel(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: getDate(map['date']),
      mood: map['mood'] ?? 'Neutral',
      createdAt: getDate(map['createdAt']),
      updatedAt: getDate(map['updatedAt']),
      images: List<String>.from(map['images'] ?? []),
    );
  }
}
