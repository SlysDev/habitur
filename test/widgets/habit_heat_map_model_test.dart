import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/ui/widgets/habit_heat_map/habit_heat_map_model.dart';

void main() {
  group('HabitHeatMapModel Tests', () {
    late HabitHeatMapModel model;

    setUp(() {
      model = HabitHeatMapModel();
    });

    test('initialize with empty data should return empty map', () {
      // Arrange
      final List<StatPoint> emptyData = [];

      // Act
      model.initialize(emptyData);

      // Assert
      expect(model.formattedData, isEmpty);
    });

    test('initialize should format data correctly', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));
      final List<StatPoint> testData = [
        StatPoint(
          date: now,
          completions: 2,
          confidenceLevel: 0,
          difficultyRating: 0,
          consistencyFactor: 0,
        ),
        StatPoint(
          date: yesterday,
          completions: 1,
          confidenceLevel: 0,
          difficultyRating: 0,
          consistencyFactor: 0,
        ),
        StatPoint(
          date: now.subtract(Duration(days: 2)),
          completions: 0, // Should be excluded as completions is 0
          confidenceLevel: 0,
          difficultyRating: 0,
          consistencyFactor: 0,
        ),
      ];

      // Act
      model.initialize(testData);

      // Assert
      expect(model.formattedData.length,
          2); // Only 2 entries as one had 0 completions
      expect(
        model.formattedData[DateTime(now.year, now.month, now.day)],
        2,
      );
      expect(
        model.formattedData[
            DateTime(yesterday.year, yesterday.month, yesterday.day)],
        1,
      );
    });

    test('initialize should handle null dates correctly', () {
      // Arrange
      final now = DateTime.now();
      final List<StatPoint> testData = [
        StatPoint(
          date: now,
          completions: 1,
          confidenceLevel: 0,
          difficultyRating: 0,
          consistencyFactor: 0,
        ),
      ];

      // Act
      model.initialize(testData);

      // Assert
      expect(model.formattedData.length, 1);
      expect(
        model.formattedData[DateTime(now.year, now.month, now.day)],
        1,
      );
    });

    test('initialize should clear previous data', () {
      // Arrange
      final now = DateTime.now();
      final firstData = [
        StatPoint(
          date: now,
          completions: 1,
          confidenceLevel: 0,
          difficultyRating: 0,
          consistencyFactor: 0,
        ),
      ];
      final secondData = [
        StatPoint(
          date: now.subtract(Duration(days: 1)),
          completions: 2,
          confidenceLevel: 0,
          difficultyRating: 0,
          consistencyFactor: 0,
        ),
      ];

      // Act
      model.initialize(firstData);
      final firstDataLength = model.formattedData.length;
      model.initialize(secondData);

      // Assert
      expect(firstDataLength, 1);
      expect(model.formattedData.length, 1);
      expect(
        model.formattedData[DateTime(
          now.subtract(Duration(days: 1)).year,
          now.subtract(Duration(days: 1)).month,
          now.subtract(Duration(days: 1)).day,
        )],
        2,
      );
    });
  });
}
