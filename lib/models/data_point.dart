import 'package:habitur/models/habit.dart';

class DataPoint {
  var value;
  DateTime date;
  late Habit habit;
  DataPoint({required this.date, required this.value});
}
