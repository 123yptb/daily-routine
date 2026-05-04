import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
enum TaskStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  success,
  @HiveField(2)
  failed,
  @HiveField(3)
  rescheduled,
}

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  DateTime? scheduledAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  late TaskStatus status;

  @HiveField(7)
  double? satisfactionRating; // 1-5 stars

  @HiveField(8)
  String? parentTaskId; // For nested tasks

  @HiveField(9)
  List<String> subTaskIds; // Children task IDs

  @HiveField(10)
  String? category; // e.g., 'calls', 'sales', 'fitness', 'reading'

  @HiveField(11)
  String? rescheduledToDate; // ISO string of rescheduled date

  @HiveField(12)
  double? goalValue; // For habit tasks (e.g., read 10 pages)

  @HiveField(13)
  double? actualValue; // Actual accomplished (e.g., 8 pages)

  @HiveField(14)
  bool isHabitTask;

  @HiveField(15)
  String? note; // Personal note added after task completion

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.scheduledAt,
    this.completedAt,
    this.status = TaskStatus.pending,
    this.satisfactionRating,
    this.parentTaskId,
    List<String>? subTaskIds,
    this.category,
    this.rescheduledToDate,
    this.goalValue,
    this.actualValue,
    this.isHabitTask = false,
    this.note,
  }) : subTaskIds = subTaskIds ?? [];

  double get deficitValue {
    if (goalValue == null || actualValue == null) return 0;
    return (goalValue! - actualValue!).clamp(0, double.infinity);
  }

  bool get hasDeficit => deficitValue > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'scheduledAt': scheduledAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status.index,
        'satisfactionRating': satisfactionRating,
        'parentTaskId': parentTaskId,
        'subTaskIds': subTaskIds,
        'category': category,
        'goalValue': goalValue,
        'actualValue': actualValue,
        'isHabitTask': isHabitTask,
        'note': note,
      };
}
