import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/services/measurement_analytics_service.dart';
import 'package:stacked/stacked.dart';

class MeasurementAnalyticsModel extends BaseViewModel {
  final _analyticsService = locator<MeasurementAnalyticsService>();

  final List<StatPoint> stats;
  final double targetGoal;

  MeasurementAnalyticsModel({
    required this.stats,
    required this.targetGoal,
  });

  double get averageDaily =>
      _analyticsService.calculateRollingAverage(stats, 7);
  double get bestDay => _analyticsService.getPersonalBest(stats);
  double get total =>
      stats.fold(0.0, (sum, stat) => sum + stat.completions.toDouble());
  double get goalProgress => _analyticsService.calculateGoalProgress(
        stats.isNotEmpty ? stats.first.completions.toDouble() : 0,
        targetGoal,
      );

  double get consistencyScore =>
      _analyticsService.calculateConsistencyScore(stats);

  List<String> get insights =>
      _analyticsService.generateInsights(stats, targetGoal);
}
