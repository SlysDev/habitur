import 'package:habitur/services/stats/stats_calculation_service.dart';

import '../app/app.locator.dart';
import '../models/stat_point.dart';

class InsightGeneratorService {
  final _statsCalculationService = locator<StatsCalculationService>();

  Map<String, dynamic> findAreaForImprovement(List<StatPoint> stats,
      {int period = 7, bool isSummary = false}) {
    Map<String, dynamic> worstSlopeData =
        _statsCalculationService.findWorstSlope(stats, period: period);
    String worstSlopeName = worstSlopeData['name'] as String;
    dynamic worstSlopeValue = worstSlopeData['value'];
    double percentChange = _statsCalculationService
        .calculatePercentChangeForStat(worstSlopeName, stats);
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

    if (worstSlopeValue == null) {
      return {
        'area': '',
        'message': {
          'preText': 'All stats have kept',
          'percentChange': 'stable',
          'postText': 'in the past ${period} days.',
          'fullText':
              'All habit stats have kept stable in the past ${period} days.'
        }
      };
    } else if (worstSlopeValue >= 0.0) {
      return {
        'area': '',
        'message': {
          'preText': 'All stats have been',
          'percentChange': 'improving or staying the same',
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
