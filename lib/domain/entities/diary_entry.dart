import 'package:equatable/equatable.dart';

class DiaryEntry extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    date,
    mood,
    createdAt,
    updatedAt,
  ];
}
