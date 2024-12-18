import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockUserService extends Mock implements UserService {}

void main() {
  group('SharedHabitsService Tests', () {
    late SharedHabitsService sharedHabitsService;
    late MockDatabaseService mockDatabaseService;
    late MockUserService mockUserService;

    setUp(() {
      setupLocator();
      mockDatabaseService = MockDatabaseService();
      mockUserService = MockUserService();
      locator.registerSingleton<DatabaseService>(mockDatabaseService);
      locator.registerSingleton<UserService>(mockUserService);
      sharedHabitsService = SharedHabitsService();
    });

    tearDown(() {
      locator.reset();
    });

    test('getSharedHabits returns empty list when user is not logged in',
        () async {
      // Arrange
      when(mockUserService.currentUser).thenReturn(null);

      // Act
      final result = await sharedHabitsService.getSharedHabits();

      // Assert
      expect(result, isEmpty);
      verifyNever(mockDatabaseService.getSharedHabits(any));
    });

    test('getSharedHabits returns list of shared habits for logged in user',
        () async {
      // Arrange
      final testUser = User(
        uid: 'test-uid',
        username: 'testuser',
        email: 'test@test.com',
        dateCreated: DateTime.now(),
        lastSeen: DateTime.now(),
      );
      final testHabit = Habit(
        id: 1,
        title: 'Test Habit',
        type: 'Exercise',
        targetGoal: 1,
        frequency: HabitFrequency.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: testUser.uid,
      );
      final testSharedHabit = SharedHabit(
        id: 1,
        habit: testHabit,
        description: 'Test Description',
        participantData: [],
        author: testUser,
      );

      when(mockUserService.currentUser).thenReturn(testUser);
      when(mockDatabaseService.getSharedHabits(testUser.uid))
          .thenAnswer((_) async => [testSharedHabit]);

      // Act
      final result = await sharedHabitsService.getSharedHabits();

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.id, equals(testSharedHabit.id));
      verify(mockDatabaseService.getSharedHabits(testUser.uid)).called(1);
    });

    test('createSharedHabit adds current user as participant if not included',
        () async {
      // Arrange
      final testUser = User(
        uid: 'test-uid',
        username: 'testuser',
        email: 'test@test.com',
        dateCreated: DateTime.now(),
        lastSeen: DateTime.now(),
      );
      final testHabit = Habit(
        id: 1,
        title: 'Test Habit',
        type: 'Exercise',
        targetGoal: 1,
        frequency: HabitFrequency.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: testUser.uid,
      );
      final testSharedHabit = SharedHabit(
        id: 1,
        habit: testHabit,
        description: 'Test Description',
        participantData: [],
        author: testUser,
      );

      when(mockUserService.currentUser).thenReturn(testUser);

      // Act
      await sharedHabitsService.createSharedHabit(testSharedHabit);

      // Assert
      verify(mockDatabaseService.createSharedHabit(any)).called(1);
      final captured = verify(mockDatabaseService.createSharedHabit(captureAny))
          .captured
          .first as SharedHabit;
      expect(captured.participantData.any((p) => p.userId == testUser.uid),
          isTrue);
    });

    test('updateParticipantProgress updates completion count', () async {
      // Arrange
      final testUser = User(
        uid: 'test-uid',
        username: 'testuser',
        email: 'test@test.com',
        dateCreated: DateTime.now(),
        lastSeen: DateTime.now(),
      );
      final testHabit = Habit(
        id: 1,
        title: 'Test Habit',
        type: 'Exercise',
        targetGoal: 2,
        frequency: HabitFrequency.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: testUser.uid,
      );
      final testSharedHabit = SharedHabit(
        id: 1,
        habit: testHabit,
        description: 'Test Description',
        participantData: [
          ParticipantData(
            user: testUser,
            fullCompletionCount: 0,
            currentCompletions: 1,
            lastSeen: DateTime.now(),
          ),
        ],
        author: testUser,
      );

      // Act
      await sharedHabitsService.updateParticipantProgress(
        testSharedHabit,
        testUser.uid,
        2,
      );

      // Assert
      verify(mockDatabaseService.updateSharedHabit(any)).called(1);
      final captured = verify(mockDatabaseService.updateSharedHabit(captureAny))
          .captured
          .first as SharedHabit;
      final participant =
          captured.participantData.firstWhere((p) => p.userId == testUser.uid);
      expect(participant.currentCompletions, equals(2));
      expect(participant.fullCompletionCount, equals(1));
    });
  });
}
