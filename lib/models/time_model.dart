import 'package:hive/hive.dart';

part 'time_model.g.dart';

@HiveType(typeId: 3)
class TimeModel {
  @HiveField(0)
  final int hour;
  @HiveField(1)
  final int minute;

  const TimeModel({required this.hour, required this.minute});
}
