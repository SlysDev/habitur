import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';

class HabitInsightsGenerator {
  Habit habit;
  HabitStatisticsCalculator statsCalculator;

  HabitInsightsGenerator(this.habit, this.statsCalculator);
  Map<String, dynamic> findAreaForImprovement() {
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
    Map<String, dynamic> worstSlopeData = statsCalculator.findWorstSlope();
    String worstSlopeName = worstSlopeData['name'] as String;
    double worstSlopeValue = worstSlopeData['value'] as double;

    if (worstSlopeValue >= 0.0) {
      return {
        'area': '',
        'message': 'All tracked statistics are improving or staying steady!'
      };
    } else {
      String improvementPeriod = '';
      switch (worstSlopeName) {
        case 'completions':
          improvementPeriod = 'days';
          break;
        case 'confidenceLevel':
          improvementPeriod = 'days';
          break;
        case 'difficultyRating':
          // Improvement period might not be applicable for difficulty
          break;
        case 'consistencyFactor':
          // Improvement period might not be applicable for consistency
          break;
        default:
          improvementPeriod = ''; // Handle unexpected statistic names
      }

      return {
        'area': worstSlopeName,
        'message':
            'Your $worstSlopeName seems to be declining. Consider strategies to improve over the past ${improvementPeriod.isEmpty ? '' : improvementPeriod + ' '}'
      };
    }
  }
}
