import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/diary_entry.dart';

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

  @HiveField(8)
  final List<String> tags;

  DiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.tags = const [],
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
      'tags': tags,
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
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  DiaryEntry toEntity() {
    return DiaryEntry(
      id: id,
      title: title,
      content: content,
      date: date,
      mood: mood,
      createdAt: createdAt,
      updatedAt: updatedAt,
      images: images,
      tags: tags,
    );
  }

  factory DiaryEntryModel.fromEntity(DiaryEntry entity) {
    return DiaryEntryModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      date: entity.date,
      mood: entity.mood,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      images: entity.images,
      tags: entity.tags,
    );
  }
}
