import 'package:habitur/models/data_point.dart';
class DayStatistic {
  final DateTime date;
  final double averageConfidence;
  final int completions;

  DayStatistic({
    required this.date,
    required this.averageConfidence,
    required this.completions,
  });

  DataPoint toDataPoint(String type) {
	  if (type == 'confidence') {
    return DataPoint(date: date, value: averageConfidence);
	  } else if (type == 'completion') {
    return DataPoint(date: date, value: completions);
	  } else {
		  throw 'Please specify type of stat to convert to a datapoint object';
	  }
  }
