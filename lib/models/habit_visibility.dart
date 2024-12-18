import 'package:hive/hive.dart';

part 'habit_visibility.g.dart';

@HiveType(typeId: 7)
class HabitVisibility extends HiveObject {
  @HiveField(0)
  final String habitId;

  @HiveField(1)
  bool isVisible;

  HabitVisibility({
    required this.habitId,
    this.isVisible = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'isVisible': isVisible,
    };
  }

  factory HabitVisibility.fromMap(Map<String, dynamic> map) {
    return HabitVisibility(
      habitId: map['habitId'] as String,
      isVisible: map['isVisible'] as bool,
    );
  }
}
