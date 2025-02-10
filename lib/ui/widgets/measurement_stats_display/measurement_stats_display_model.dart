import 'package:stacked/stacked.dart';
import 'package:habitur/models/stat_point.dart';

class MeasurementStatsDisplayModel extends BaseViewModel {
  double _totalMeasurements = 0;
  double _averagePerDay = 0;
  double _highestInOneDay = 0;

  double get totalMeasurements => _totalMeasurements;
  double get averagePerDay => _averagePerDay;
  double get highestInOneDay => _highestInOneDay;

  void initialize(List<StatPoint> stats) {
    if (stats.isEmpty) return;

    _totalMeasurements = stats.fold(0, (sum, stat) => sum + stat.completions);
    _averagePerDay = _totalMeasurements / stats.length;
    _highestInOneDay = stats
        .map((stat) => stat.completions)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    notifyListeners();
  }
}
