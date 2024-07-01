class StatPoint {
  DateTime date;

  int completions;
  double completionRate;
  double confidenceLevel;
  int streak;
  double consistencyRate;

  double
      difficultyRating; // User-reported difficulty rating (1.0 - easy, 5.0 - difficult)

  // Slope information for various statistics
  double slopeCompletions;
  double
      slopeConfidenceLevel; // You can replace 'ConfidenceLevel' with your actual statistic name
  double slopeConsistency;
  double slopeDifficultyRating;
  double slopeCompletionRate;

  StatPoint({
    required this.date,
    required this.completions,
    this.confidenceLevel = 1,
    required this.streak,
    this.completionRate = 0.0,
    this.consistencyRate = 0.0,
    this.difficultyRating = 0.0,
    this.slopeCompletions = 0.0,
    this.slopeConfidenceLevel = 0.0,
    this.slopeConsistency = 0.0,
    this.slopeDifficultyRating = 0.0,
    this.slopeCompletionRate = 0.0,
  });
}
