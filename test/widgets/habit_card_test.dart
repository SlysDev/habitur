import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/ui/widgets/habit_card/habit_card.dart';

void main() {
  testWidgets('HabitCard displays habit title', (WidgetTester tester) async {
    // Arrange
    final habit = Habit(
      id: '1',
      title: 'Test Habit',
      isCompleted: false,
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: HabitCard(habit: habit),
      ),
    );

    // Assert
    expect(find.text('Test Habit'), findsOneWidget);
  });
}
