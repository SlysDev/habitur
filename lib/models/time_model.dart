import 'package:hive/hive.dart';

part 'time_model.g.dart';

@HiveType(typeId: 3)
class TimeModel {
  @HiveField(0)
  final int hour;
  @HiveField(1)
  final int minute;

  const TimeModel({required this.hour, required this.minute});

  TimeModel copyWith({
    int? hour,
    int? minute,
  }) {
    return TimeModel(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  DateTime toDateTime() {
    return DateTime(0, 0, 0, hour, minute);
  }

  factory TimeModel.fromDateTime(DateTime dateTime) {
    return TimeModel(hour: dateTime.hour, minute: dateTime.minute);
  }
}
