// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 2;

  @override
  JournalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntry(
      id: fields[0] as String,
      content: fields[1] as String,
      date: fields[2] as DateTime,
      mood: fields[3] as String?,
      moodScore: fields[4] as double?,
      tags: (fields[5] as List?)?.cast<String>(),
      isFavorite: fields[6] as bool,
      title: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.moodScore)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 3;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      taskIds: (fields[2] as List?)?.cast<String>(),
      overallScore: fields[3] as double?,
      avgSatisfactionRating: fields[4] as double?,
      totalTasks: fields[5] as int,
      completedTasks: fields[6] as int,
      failedTasks: fields[7] as int,
      journalEntryId: fields[8] as String?,
      carryOverDeficit: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.taskIds)
      ..writeByte(3)
      ..write(obj.overallScore)
      ..writeByte(4)
      ..write(obj.avgSatisfactionRating)
      ..writeByte(5)
      ..write(obj.totalTasks)
      ..writeByte(6)
      ..write(obj.completedTasks)
      ..writeByte(7)
      ..write(obj.failedTasks)
      ..writeByte(8)
      ..write(obj.journalEntryId)
      ..writeByte(9)
      ..write(obj.carryOverDeficit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
