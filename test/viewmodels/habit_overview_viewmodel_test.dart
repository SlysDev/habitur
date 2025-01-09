import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/ui/views/habit_overview/habit_overview_viewmodel.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('HabitOverviewViewModel Tests -', () {
    setUp(() {
      registerServices();
    });

    tearDown(() => locator.reset());

    test('initialize fetches habit data', () async {
      // Arrange
      final habitService = locator<HabitService>() as MockHabitService;
      final habit = Habit(
        id: '1',
        title: 'Test Habit',
        isCompleted: false,
      );
      when(habitService.getHabit('1')).thenAnswer((_) async => habit);

      final model = HabitOverviewViewModel();

      // Act
      await model.initialize('1');

      // Assert
      expect(model.habit, habit);
      verify(habitService.getHabit('1')).called(1);
    });
  });
}
