import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';

const _uuid = Uuid();
const _habitsBox = 'habits';

class HabitNotifier extends StateNotifier<List<HabitModel>> {
  HabitNotifier() : super([]) {
    _loadHabits();
  }

  Box<HabitModel> get _box => Hive.box<HabitModel>(_habitsBox);

  void _loadHabits() {
    state = _box.values.toList();
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String get _todayKey => _dateKey(DateTime.now());

  Future<HabitModel> addHabit({
    required String name,
    String? description,
    required double targetValue,
    required String unit,
    HabitFrequency frequency = HabitFrequency.daily,
    String? colorHex,
    String? iconName,
  }) async {
    final habit = HabitModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      targetValue: targetValue,
      unit: unit,
      frequency: frequency,
      createdAt: DateTime.now(),
      colorHex: colorHex,
      iconName: iconName,
    );
    await _box.put(habit.id, habit);
    _loadHabits();
    return habit;
  }

  /// Log progress for a habit on today — implements Adaptive Buffer logic
  Future<void> logProgress(String habitId, double value) async {
    final habit = _box.get(habitId);
    if (habit == null) return;

    final today = _todayKey;
    habit.completionLog[today] = value;

    // Compute carry-over buffer:
    // negative = deficit (needs catchup), positive = surplus
    final deficit = habit.targetValue - value;
    habit.carryOverBuffer = habit.carryOverBuffer - deficit;
    // clamp so surplus can't exceed 2x target
    habit.carryOverBuffer =
        habit.carryOverBuffer.clamp(-habit.targetValue * 3, habit.targetValue * 2);

    // Update streak
    _updateStreak(habit);

    await habit.save();
    _loadHabits();
  }

  void _updateStreak(HabitModel habit) {
    int streak = 0;
    DateTime check = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final key = _dateKey(check);
      if (habit.isCompletedForDate(key)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    habit.currentStreak = streak;
    if (streak > habit.longestStreak) habit.longestStreak = streak;
  }

  Future<void> deleteHabit(String habitId) async {
    await _box.delete(habitId);
    _loadHabits();
  }

  /// Returns last N days of progress data for a habit
  List<Map<String, dynamic>> getProgressData(String habitId, {int days = 7}) {
    final habit = _box.get(habitId);
    if (habit == null) return [];
    return List.generate(days, (i) {
      final date = DateTime.now().subtract(Duration(days: days - 1 - i));
      final key = _dateKey(date);
      return {
        'date': date,
        'key': key,
        'actual': habit.completionLog[key] ?? 0.0,
        'target': habit.targetValue,
        'completed': habit.isCompletedForDate(key),
      };
    });
  }

  HabitModel? getHabit(String id) => _box.get(id);
}

final habitProvider =
    StateNotifierProvider<HabitNotifier, List<HabitModel>>((_) => HabitNotifier());
