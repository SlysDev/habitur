import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';
import 'package:habitur/modules/stats_calculator.dart';

class InsightsGenerator {
  List<StatPoint> stats;
  bool isSummary;

  InsightsGenerator(this.stats, {this.isSummary = false});
  Map<String, dynamic> findAreaForImprovement({int period = 7}) {
    StatisticsCalculator statsCalculator = StatisticsCalculator();
    Map<String, dynamic> worstSlopeData =
        statsCalculator.findWorstSlope(stats, period: period);
    String worstSlopeName = worstSlopeData['name'] as String;
    double worstSlopeValue = worstSlopeData['value'] as double;
    double percentChange =
        statsCalculator.calculatePercentChangeForStat(worstSlopeName, stats);
    String worstSlopeNameFormatted;
    String postInsight = '';
    switch (worstSlopeName) {
      case 'completions':
        worstSlopeNameFormatted = 'completion count';
        postInsight =
            'Try "chaining" ${isSummary ? 'habits with ones' : 'it with another habit'} you\'re more comfortable with!';
        break;
      case 'confidenceLevel':
        worstSlopeNameFormatted = 'confidence level';
        postInsight = 'To build confidence, try building a streak!';
        break;
      case 'difficultyRating':
        worstSlopeNameFormatted = 'difficulty rating';
        postInsight =
            'Try making your ${isSummary ? 'habits' : 'habit'} easier––you can ratchet things up with time.';
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
          'preText':
              '${isSummary ? 'Your overall' : 'This habit\'s'} $worstSlopeNameFormatted has declined ${percentChange != 0.0 ? 'by' : ''}',
          'percentChange': percentChange.abs().toStringAsFixed(1) + "%",
          'postText': 'in the past ${period} days. $postInsight',
          'fullText':
              '${isSummary ? 'Your overall' : 'This habit\'s'} $worstSlopeNameFormatted has declined by $percentChange% in the past ${period} days.'
        },
      };
    }
  }
}
