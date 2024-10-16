import 'package:habitur/models/stat_point.dart';

List<StatPoint> mockStatPoints = [
  StatPoint(
    date: DateTime.now().subtract(const Duration(days: 6)),
    completions: 3,
    confidenceLevel: 0.7,
    streak: 1,
    consistencyFactor: 0.75,
    difficultyRating: 3.0,
    slopeCompletions: 0.1,
    slopeConfidenceLevel: 0.05,
    slopeConsistency: 0.03,
    slopeDifficultyRating: -0.1,
  ),
  StatPoint(
    date: DateTime.now().subtract(const Duration(days: 5)),
    completions: 4,
    confidenceLevel: 0.8,
    streak: 2,
    consistencyFactor: 0.8,
    difficultyRating: 2.8,
    slopeCompletions: 0.2,
    slopeConfidenceLevel: 0.1,
    slopeConsistency: 0.05,
    slopeDifficultyRating: -0.2,
  ),
  StatPoint(
    date: DateTime.now().subtract(const Duration(days: 4)),
    completions: 5,
    confidenceLevel: 0.85,
    streak: 3,
    consistencyFactor: 0.85,
    difficultyRating: 2.5,
    slopeCompletions: 0.2,
    slopeConfidenceLevel: 0.05,
    slopeConsistency: 0.02,
    slopeDifficultyRating: -0.3,
  ),
  StatPoint(
    date: DateTime.now().subtract(const Duration(days: 3)),
    completions: 4,
    confidenceLevel: 0.8,
    streak: 4,
    consistencyFactor: 0.9,
    difficultyRating: 3.2,
    slopeCompletions: -0.1,
    slopeConfidenceLevel: -0.05,
    slopeConsistency: 0.02,
    slopeDifficultyRating: 0.4,
  ),
  StatPoint(
    date: DateTime.now().subtract(const Duration(days: 2)),
    completions: 6,
    confidenceLevel: 0.9,
    streak: 5,
    consistencyFactor: 0.95,
    difficultyRating: 2.9,
    slopeCompletions: 0.2,
    slopeConfidenceLevel: 0.05,
    slopeConsistency: 0.05,
    slopeDifficultyRating: -0.3,
  ),
  StatPoint(
    date: DateTime.now().subtract(const Duration(days: 1)),
    completions: 2,
    confidenceLevel: 0.75,
    streak: 0,
    consistencyFactor: 0.7,
    difficultyRating: 3.5,
    slopeCompletions: -0.3,
    slopeConfidenceLevel: -0.15,
    slopeConsistency: -0.1,
    slopeDifficultyRating: 0.6,
  ),
  StatPoint(
    date: DateTime.now(),
    completions: 5,
    confidenceLevel: 0.8,
    streak: 1,
    consistencyFactor: 0.85,
    difficultyRating: 2.7,
    slopeCompletions: 0.15,
    slopeConfidenceLevel: 0.05,
    slopeConsistency: 0.1,
    slopeDifficultyRating: -0.2,
  ),
];
