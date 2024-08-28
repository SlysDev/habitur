import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/stat_point.dart';

class DataConverter {
  List<DataPoint> dbListToDataPoints(input) {
    if (input.isNotEmpty) {
      return input.map<DataPoint>((element) {
        if (element is Map<String, dynamic>) {
          dynamic date = element['date'];
          DateTime dateTime;
          if (date is Timestamp) {
            dateTime = date.toDate();
          } else {
            dateTime = DateTime.now(); // Handle unexpected format
            print('weird formatting, used DateTime.now() for this one.');
          }
          return DataPoint(date: dateTime, value: element['value']);
        } else {
          print('input was empty');
          return DataPoint(
              date: DateTime.now(), value: 0); // Handle unexpected format
        }
      }).toList();
    } else {
      return [];
    }
  }

  List<StatPoint> dbListToStatPoints(input) {
    if (input.isNotEmpty) {
      return input.map<StatPoint>((element) {
        if (element is Map<String, dynamic>) {
          dynamic date = element['date'];
          DateTime dateTime;
          if (date is Timestamp) {
            dateTime = date.toDate();
          } else {
            dateTime = DateTime.now(); // Handle unexpected format
            print('weird formatting, used DateTime.now() for this one.');
          }
          return StatPoint(
            date: dateTime,
            completions: element['completions'] ?? 0,
            confidenceLevel: element['confidenceLevel'] != null
                ? element['confidenceLevel'].toDouble()
                : 0,
            streak: element['streak'] ?? 0,
            difficultyRating: (element['difficultyRating'] ?? 0).toDouble(),
            slopeCompletions: (element['slopeCompletions'] ?? 0).toDouble(),
            slopeConfidenceLevel:
                (element['slopeConfidenceLevel'] ?? 0).toDouble(),
            slopeConsistency: (element['slopeConsistency'] ?? 0).toDouble(),
            slopeDifficultyRating:
                (element['slopeDifficultyRating'] ?? 0).toDouble(),
          );
        } else {
          print('input was empty');
          return StatPoint(
              date: DateTime.now(),
              completions: 0,
              confidenceLevel: 1,
              streak: 0); // Handle unexpected format
        }
      }).toList();
    } else {
      return [];
    }
  }

  List<Map<String, dynamic>> dbStatPointsToMap(List<StatPoint> statPoints) {
    return statPoints
        .map<Map<String, dynamic>>((statPoint) => {
              'date': Timestamp.fromDate(statPoint.date),
              'completions': statPoint.completions,
              'confidenceLevel': statPoint.confidenceLevel,
              'streak': statPoint.streak,
              'difficultyRating': statPoint.difficultyRating,
              'slopeCompletions': statPoint.slopeCompletions,
              'slopeConfidenceLevel': statPoint.slopeConfidenceLevel,
              'slopeConsistency': statPoint.slopeConsistency,
              'slopeDifficultyRating': statPoint.slopeDifficultyRating,
            })
        .toList();
  }

  List<DateTime> dbListToDates(input) {
    if (input.isNotEmpty) {
      return input.map<DateTime>((date) {
        if (date is Map<String, dynamic>) {
          return date['date'].toDate() as DateTime;
        } else {
          print('weird formatting, used DateTime.now() for this one.');
          return DateTime.now(); // Handle unexpected format
        }
      }).toList();
    } else {
      return [];
    }
  }
}
