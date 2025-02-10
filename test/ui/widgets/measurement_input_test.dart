import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/ui/widgets/measurement_input/measurement_input.dart';

void main() {
  group('MeasurementInput Widget Tests', () {
    testWidgets('renders correctly with initial value', (tester) async {
      double currentValue = 10.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeasurementInput(
              value: currentValue,
              unit: 'pages',
              onChanged: (value) => currentValue = value,
            ),
          ),
        ),
      );

      expect(find.text('10.0'), findsOneWidget);
      expect(find.text('pages'), findsOneWidget);
    });

    testWidgets('increment button works correctly', (tester) async {
      double currentValue = 5.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeasurementInput(
              value: currentValue,
              unit: 'steps',
              onChanged: (value) => currentValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      expect(currentValue, 6.0);
    });

    testWidgets('decrement button works correctly', (tester) async {
      double currentValue = 5.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeasurementInput(
              value: currentValue,
              unit: 'steps',
              onChanged: (value) => currentValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();

      expect(currentValue, 4.0);
    });

    testWidgets('respects min value constraint', (tester) async {
      double currentValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeasurementInput(
              value: currentValue,
              unit: 'pages',
              minValue: 0,
              onChanged: (value) => currentValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();

      expect(currentValue, 0.0);

      // Try to go below minimum
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();

      expect(currentValue, 0.0);
    });

    testWidgets('respects max value constraint', (tester) async {
      double currentValue = 9.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeasurementInput(
              value: currentValue,
              unit: 'pages',
              maxValue: 10,
              onChanged: (value) => currentValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      expect(currentValue, 10.0);

      // Try to go above maximum
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      expect(currentValue, 10.0);
    });

    testWidgets('handles manual text input correctly', (tester) async {
      double currentValue = 5.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeasurementInput(
              value: currentValue,
              unit: 'pages',
              onChanged: (value) => currentValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '7.5');
      await tester.pump();

      expect(currentValue, 7.5);
    });
  });
}
