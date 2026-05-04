// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 0;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.pending;
      case 1:
        return TaskStatus.success;
      case 2:
        return TaskStatus.failed;
      case 3:
        return TaskStatus.rescheduled;
      default:
        return TaskStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.pending:
        writer.writeByte(0);
        break;
      case TaskStatus.success:
        writer.writeByte(1);
        break;
      case TaskStatus.failed:
        writer.writeByte(2);
        break;
      case TaskStatus.rescheduled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 1;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      scheduledAt: fields[4] as DateTime?,
      completedAt: fields[5] as DateTime?,
      status: fields[6] as TaskStatus,
      satisfactionRating: fields[7] as double?,
      parentTaskId: fields[8] as String?,
      subTaskIds: (fields[9] as List?)?.cast<String>(),
      category: fields[10] as String?,
      rescheduledToDate: fields[11] as String?,
      goalValue: fields[12] as double?,
      actualValue: fields[13] as double?,
      isHabitTask: fields[14] as bool,
      note: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.scheduledAt)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.satisfactionRating)
      ..writeByte(8)
      ..write(obj.parentTaskId)
      ..writeByte(9)
      ..write(obj.subTaskIds)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.rescheduledToDate)
      ..writeByte(12)
      ..write(obj.goalValue)
      ..writeByte(13)
      ..write(obj.actualValue)
      ..writeByte(14)
      ..write(obj.isHabitTask)
      ..writeByte(15)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
