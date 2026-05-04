import 'package:hive/hive.dart';

part 'journal_model.g.dart';

@HiveType(typeId: 2)
class JournalEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  String? mood; // 'great', 'good', 'okay', 'bad', 'terrible'

  @HiveField(4)
  double? moodScore; // 1-10

  @HiveField(5)
  List<String>? tags;

  @HiveField(6)
  bool isFavorite;

  @HiveField(7)
  String? title;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    this.mood,
    this.moodScore,
    this.tags,
    this.isFavorite = false,
    this.title,
  });
}

@HiveType(typeId: 3)
class DailyLog extends HiveObject {
  @HiveField(0)
  late String id; // Format: 'yyyy-MM-dd'

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  List<String> taskIds;

  @HiveField(3)
  double? overallScore; // Computed daily performance score (0-100)

  @HiveField(4)
  double? avgSatisfactionRating;

  @HiveField(5)
  int totalTasks;

  @HiveField(6)
  int completedTasks;

  @HiveField(7)
  int failedTasks;

  @HiveField(8)
  String? journalEntryId;

  @HiveField(9)
  double? carryOverDeficit; // Deficit carried from previous day

  DailyLog({
    required this.id,
    required this.date,
    List<String>? taskIds,
    this.overallScore,
    this.avgSatisfactionRating,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.failedTasks = 0,
    this.journalEntryId,
    this.carryOverDeficit,
  }) : taskIds = taskIds ?? [];

  double get successRate {
    if (totalTasks == 0) return 0;
    return (completedTasks / totalTasks) * 100;
  }

  double get computedScore {
    final srScore = successRate * 0.5; // 50% weight
    final ratingScore = (avgSatisfactionRating ?? 0) / 5 * 100 * 0.5; // 50% weight
    return (srScore + ratingScore).clamp(0, 100);
  }
}
