import 'package:stacked/stacked.dart';
import 'package:habitur/models/stat_point.dart';

class HabitHeatMapModel extends BaseViewModel {
  Map<DateTime, int> _formattedData = {};
  Map<DateTime, int> get formattedData => _formattedData;

  void initialize(List<StatPoint> data) {
    _formattedData = {};
    for (StatPoint dataPoint in data) {
      DateTime date = dataPoint.date;
      if (dataPoint.completions != 0) {
        _formattedData[DateTime(date.year, date.month, date.day)] =
            dataPoint.completions;
      }
    }
    notifyListeners();
  }
}
