import 'package:hive/hive.dart';

part 'stat_point.g.dart';

@HiveType(typeId: 1)
class StatPoint {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int completions;
  @HiveField(2)
  double consistencyFactor;
  @HiveField(3)
  double confidenceLevel;
  @HiveField(4)
  int streak;

  @HiveField(5)
  double
      difficultyRating; // User-reported difficulty rating (1.0 - easy, 5.0 - difficult)

  // Slope information for various statistics
  @HiveField(6)
  double slopeCompletions;
  @HiveField(7)
  double
      slopeConfidenceLevel; // You can replace 'ConfidenceLevel' with your actual statistic name
  @HiveField(8)
  double slopeConsistency;
  @HiveField(9)
  double slopeDifficultyRating;

  StatPoint({
    required this.date,
    required this.completions,
    this.confidenceLevel = 0,
    required this.streak,
    this.consistencyFactor = 0.0,
    this.difficultyRating = 0.0,
    this.slopeCompletions = 0.0,
    this.slopeConfidenceLevel = 0.0,
    this.slopeConsistency = 0.0,
    this.slopeDifficultyRating = 0.0,
  });
  // for converting from JSON (local storage)
  factory StatPoint.fromJson(Map<String, dynamic> json) {
    return StatPoint(
      date: DateTime.parse(
          json['date']), // Assuming date is stored as a string in Hive
      completions: json['completions'],
      confidenceLevel: json['confidenceLevel'] as double,
      streak: json['streak'],
      consistencyFactor: json['consistencyFactor'] as double,
      difficultyRating: json['difficultyRating'] as double,
      slopeCompletions: json['slopeCompletions'] as double,
      slopeConfidenceLevel: json['slopeConfidenceLevel'] as double,
      slopeConsistency: json['slopeConsistency'] as double,
      slopeDifficultyRating: json['slopeDifficultyRating'] as double,
    );
  }
}
