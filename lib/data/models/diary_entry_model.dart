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

  DiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.createdAt,
    required this.updatedAt,
  });
}
