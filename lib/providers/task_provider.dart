import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/journal_model.dart';

const _uuid = Uuid();
const _tasksBox = 'tasks';
const _logsBox = 'daily_logs';

// ─── Task Notifier ─────────────────────────────────────────────────────────
class TaskNotifier extends StateNotifier<List<TaskModel>> {
  TaskNotifier() : super([]) {
    _loadTasks();
  }

  Box<TaskModel> get _box => Hive.box<TaskModel>(_tasksBox);

  void _loadTasks() {
    state = _box.values.toList();
  }

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  List<TaskModel> get todayTasks {
    final today = _todayKey;
    return state.where((t) {
      final taskDate = t.scheduledAt ?? t.createdAt;
      return DateFormat('yyyy-MM-dd').format(taskDate) == today &&
          t.parentTaskId == null;
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<TaskModel> getSubTasks(String parentId) {
    return state.where((t) => t.parentTaskId == parentId).toList();
  }

  Future<TaskModel> addTask({
    required String title,
    String? description,
    String? category,
    String? parentTaskId,
    DateTime? scheduledAt,
    double? goalValue,
    String? unit,
    bool isHabitTask = false,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt ?? DateTime.now(),
      status: TaskStatus.pending,
      category: category,
      parentTaskId: parentTaskId,
      goalValue: goalValue,
      isHabitTask: isHabitTask,
    );

    await _box.put(task.id, task);

    if (parentTaskId != null) {
      final parent = _box.get(parentTaskId);
      if (parent != null) {
        parent.subTaskIds.add(task.id);
        await parent.save();
      }
    }

    _loadTasks();
    _updateDailyLog();
    return task;
  }

  Future<void> completeTask(
    String taskId, {
    required double rating,
    double? actualValue,
    String? note,
  }) async {
    final task = _box.get(taskId);
    if (task == null) return;
    task.status = TaskStatus.success;
    task.satisfactionRating = rating;
    task.completedAt = DateTime.now();
    task.actualValue = actualValue ?? task.goalValue;
    task.note = note;
    await task.save();
    _loadTasks();
    _updateDailyLog();
  }

  Future<void> failTask(String taskId, {String? note}) async {
    final task = _box.get(taskId);
    if (task == null) return;
    task.status = TaskStatus.failed;
    task.completedAt = DateTime.now();
    task.note = note;
    await task.save();
    _loadTasks();
    _updateDailyLog();
  }

  Future<void> rescheduleTask(String taskId, DateTime newDate) async {
    final task = _box.get(taskId);
    if (task == null) return;
    task.status = TaskStatus.rescheduled;
    task.rescheduledToDate = DateFormat('yyyy-MM-dd').format(newDate);
    task.scheduledAt = newDate;
    await task.save();
    _loadTasks();
    _updateDailyLog();
  }

  Future<void> deleteTask(String taskId) async {
    final task = _box.get(taskId);
    if (task == null) return;
    // Remove from parent's subTaskIds
    if (task.parentTaskId != null) {
      final parent = _box.get(task.parentTaskId);
      if (parent != null) {
        parent.subTaskIds.remove(taskId);
        await parent.save();
      }
    }
    // Delete subtasks too
    for (final subId in task.subTaskIds) {
      await _box.delete(subId);
    }
    await _box.delete(taskId);
    _loadTasks();
    _updateDailyLog();
  }

  void _updateDailyLog() {
    final today = _todayKey;
    final logsBox = Hive.box<DailyLog>(_logsBox);
    final todayTasks = this.todayTasks;
    final allTasks = [
      for (final t in todayTasks) ...[t, ...getSubTasks(t.id)]
    ];

    final completed =
        allTasks.where((t) => t.status == TaskStatus.success).toList();
    final failed =
        allTasks.where((t) => t.status == TaskStatus.failed).toList();
    final ratings = completed
        .where((t) => t.satisfactionRating != null)
        .map((t) => t.satisfactionRating!)
        .toList();

    final avgRating =
        ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

    DailyLog log = logsBox.get(today) ??
        DailyLog(id: today, date: DateTime.now(), taskIds: []);

    log.totalTasks = allTasks.length;
    log.completedTasks = completed.length;
    log.failedTasks = failed.length;
    log.avgSatisfactionRating = avgRating;
    log.taskIds = allTasks.map((t) => t.id).toList();
    log.overallScore = log.computedScore;

    logsBox.put(today, log);
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return state.where((t) {
      final taskDate = t.scheduledAt ?? t.createdAt;
      return DateFormat('yyyy-MM-dd').format(taskDate) == key &&
          t.parentTaskId == null;
    }).toList();
  }
}

final taskProvider =
    StateNotifierProvider<TaskNotifier, List<TaskModel>>((_) => TaskNotifier());

// ─── Daily Log Provider ────────────────────────────────────────────────────
final dailyLogProvider = Provider<DailyLog?>((ref) {
  ref.watch(taskProvider); // rebuild when tasks change
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return Hive.box<DailyLog>(_logsBox).get(today);
});

final allLogsProvider = Provider<List<DailyLog>>((ref) {
  ref.watch(taskProvider);
  return Hive.box<DailyLog>(_logsBox).values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

// ─── Score Streaks ─────────────────────────────────────────────────────────
final currentStreakProvider = Provider<int>((ref) {
  final logs = ref.watch(allLogsProvider);
  if (logs.isEmpty) return 0;
  int streak = 0;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  for (int i = logs.length - 1; i >= 0; i--) {
    final log = logs[i];
    final logKey = DateFormat('yyyy-MM-dd').format(log.date);
    final expectedDate = DateFormat('yyyy-MM-dd').format(
      DateTime.now().subtract(Duration(days: logs.length - 1 - i)),
    );
    if (logKey != expectedDate) break;
    if (logKey == today && log.completedTasks == 0) break;
    if (log.completedTasks > 0) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
});
