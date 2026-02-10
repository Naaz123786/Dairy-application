// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryEntryModelAdapter extends TypeAdapter<DiaryEntryModel> {
  @override
  final int typeId = 0;

  @override
  DiaryEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryEntryModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      date: fields[3] as DateTime,
      mood: fields[4] as String,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      images: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DiaryEntryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.mood)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
