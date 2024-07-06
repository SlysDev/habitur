import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';

class HabitInsightsGenerator {
  Habit habit;
  HabitStatisticsCalculator statsCalculator;

  HabitInsightsGenerator(this.habit, this.statsCalculator);
  Map<String, dynamic> findAreaForImprovement({int period = 7}) {
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
    Map<String, dynamic> worstSlopeData =
        statsCalculator.findWorstSlope(period: period);
    String worstSlopeName = worstSlopeData['name'] as String;
    double worstSlopeValue = worstSlopeData['value'] as double;
    double percentChange =
        statsCalculator.calculatePercentChangeForStat(worstSlopeName);
    String worstSlopeNameFormatted;
    String postInsight = '';
    switch (worstSlopeName) {
      case 'completions':
        worstSlopeNameFormatted = 'completion count';
        postInsight =
            'Try "chaining" it with another habit you\'re more comfortable with!';
        break;
      case 'confidenceLevel':
        worstSlopeNameFormatted = 'confidence level';
        postInsight = 'To build confidence, try building a streak!';
        break;
      case 'difficultyRating':
        worstSlopeNameFormatted = 'difficulty rating';
        postInsight =
            'Try making your habit easier––you can ratchet things up with time.';
        break;
      case 'consistencyFactor':
        worstSlopeNameFormatted = 'consistency';
        postInsight =
            'Consistency is by far the most important factor in habit growth!';
        // Improvement period might not be applicable for consistency
        break;
      default:
        worstSlopeNameFormatted = ''; // Handle unexpected statistic names
    }

    if (worstSlopeValue >= 0.0) {
      return {
        'area': '',
        'message': {
          'preText': 'All stats have been',
          'percentChange': 'improving',
          'postText': 'in the past ${period} days. Bravo!',
          'fullText':
              'All habit stats have been improving in the past ${period} days. Bravo!'
        }
      };
    } else {
      return {
        'area': worstSlopeName,
        'message': {
          'preText': 'This habit\'s $worstSlopeNameFormatted has declined by',
          'percentChange': percentChange.abs().toStringAsFixed(1) + "%",
          'postText': 'in the past ${period} days. $postInsight',
          'fullText':
              'This habit\'s $worstSlopeNameFormatted has declined by $percentChange% in the past ${period} days.'
        },
      };
    }
  }
}
