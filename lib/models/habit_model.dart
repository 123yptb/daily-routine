import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 4)
enum HabitFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  custom,
}

@HiveType(typeId: 5)
class HabitModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late double targetValue; // e.g., 10 (pages to read)

  @HiveField(4)
  late String unit; // e.g., 'pages', 'minutes', 'km'

  @HiveField(5)
  late HabitFrequency frequency;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  String? colorHex;

  @HiveField(8)
  String? iconName;

  @HiveField(9)
  int currentStreak;

  @HiveField(10)
  int longestStreak;

  @HiveField(11)
  Map<String, double> completionLog; // key: 'yyyy-MM-dd', value: actual value

  @HiveField(12)
  double carryOverBuffer; // Running deficit/surplus

  HabitModel({
    required this.id,
    required this.name,
    this.description,
    required this.targetValue,
    required this.unit,
    this.frequency = HabitFrequency.daily,
    required this.createdAt,
    this.colorHex,
    this.iconName,
    this.currentStreak = 0,
    this.longestStreak = 0,
    Map<String, double>? completionLog,
    this.carryOverBuffer = 0,
  }) : completionLog = completionLog ?? {};

  /// Adaptive Buffering Logic:
  /// If yesterday = deficit (-2 pages), today's effective target = 10 + 2 = 12
  double get effectiveTargetToday {
    final deficit = carryOverBuffer < 0 ? carryOverBuffer.abs() : 0;
    return targetValue + deficit;
  }

  double getProgressForDate(String dateKey) {
    return completionLog[dateKey] ?? 0;
  }

  double getDeficitForDate(String dateKey) {
    final actual = completionLog[dateKey] ?? 0;
    return (targetValue - actual).clamp(0, double.infinity);
  }

  bool isCompletedForDate(String dateKey) {
    final actual = completionLog[dateKey] ?? 0;
    return actual >= targetValue;
  }
}
