import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/progress.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/ui/widgets/habit_card/habit_card_model.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('HabitCardModel Tests -', () {
    setUp(() {
      registerServices();
    });

    tearDown(() => locator.reset());

    test('initialize should set completed status based on habit', () async {
      // Arrange
      final habit = Habit(
        id: '1',
        title: 'Test Habit',
        isCompleted: true,
        progress: Progress(current: 3, target: 5),
      );
      final model = HabitCardModel(habit: habit);

      // Act
      await model.initialize();

      // Assert
      expect(model.completed, true);
    });

    test('incrementHabit should call habitService.incrementHabit', () async {
      // Arrange
      final habitService = locator<HabitService>() as MockHabitService;
      final habit = Habit(
        id: '1',
        title: 'Test Habit',
        isCompleted: false,
        progress: Progress(current: 0, target: 5),
      );
      final model = HabitCardModel(habit: habit);

      when(habitService.incrementHabit(any, any)).thenAnswer((_) async => null);
      when(habitService.getHabit(any))
          .thenAnswer((_) async => habit.copyWith(isCompleted: false));

      // Act
      await model.incrementHabit();

      // Assert
      verify(habitService.incrementHabit(habit.id, any)).called(1);
    });

    test(
        'incrementHabit should update completed status when habit is completed',
        () async {
      // Arrange
      final habitService = locator<HabitService>() as MockHabitService;
      final habit = Habit(
        id: '1',
        title: 'Test Habit',
        isCompleted: false,
        progress: Progress(current: 4, target: 5),
      );
      final model = HabitCardModel(habit: habit);

      when(habitService.incrementHabit(any, any)).thenAnswer((_) async => null);
      when(habitService.getHabit(any))
          .thenAnswer((_) async => habit.copyWith(isCompleted: true));

      // Act
      await model.incrementHabit();

      // Assert
      expect(model.completed, true);
    });
  });
}
