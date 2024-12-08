import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/navigation_service.dart';
import 'package:habitur/ui/views/invite_participants/invite_participants_viewmodel.dart';
import 'package:mockito/mockito.dart';

class MockFriendsService extends Mock implements FriendsService {}
class MockSharedHabitsService extends Mock implements SharedHabitsService {}
class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('InviteParticipantsViewModel Tests', () {
    late InviteParticipantsViewModel viewModel;
    late MockFriendsService mockFriendsService;
    late MockSharedHabitsService mockSharedHabitsService;
    late MockNavigationService mockNavigationService;
    late SharedHabit testSharedHabit;
    late List<User> testFriends;

    setUp(() {
      setupLocator();
      mockFriendsService = MockFriendsService();
      mockSharedHabitsService = MockSharedHabitsService();
      mockNavigationService = MockNavigationService();
      locator.registerSingleton<FriendsService>(mockFriendsService);
      locator.registerSingleton<SharedHabitsService>(mockSharedHabitsService);
      locator.registerSingleton<NavigationService>(mockNavigationService);

      viewModel = InviteParticipantsViewModel();

      testFriends = [
        User(
          uid: 'friend1',
          username: 'friend1',
          email: 'friend1@test.com',
          dateCreated: DateTime.now(),
          lastSeen: DateTime.now(),
        ),
        User(
          uid: 'friend2',
          username: 'friend2',
          email: 'friend2@test.com',
          dateCreated: DateTime.now(),
          lastSeen: DateTime.now(),
        ),
      ];

      testSharedHabit = SharedHabit(
        id: 1,
        habit: Habit(
          id: 1,
          title: 'Test Habit',
          type: 'Exercise',
          targetGoal: 1,
          frequency: HabitFrequency.daily,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'test-uid',
        ),
        description: 'Test Description',
        participantData: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    tearDown(() {
      locator.reset();
    });

    test('init loads friends list', () async {
      // Arrange
      when(mockFriendsService.getFriends()).thenAnswer((_) async => testFriends);

      // Act
      await viewModel.init(testSharedHabit);

      // Assert
      expect(viewModel.friends, equals(testFriends));
      verify(mockFriendsService.getFriends()).called(1);
    });

    test('search filters friends correctly', () async {
      // Arrange
      when(mockFriendsService.getFriends()).thenAnswer((_) async => testFriends);
      await viewModel.init(testSharedHabit);

      // Act
      viewModel.onSearchChanged('friend1');

      // Assert
      expect(viewModel.filteredFriends.length, equals(1));
      expect(viewModel.filteredFriends.first.username, equals('friend1'));
    });

    test('toggleFriendSelection adds and removes friends', () async {
      // Arrange
      when(mockFriendsService.getFriends()).thenAnswer((_) async => testFriends);
      await viewModel.init(testSharedHabit);
      final friend = testFriends.first;

      // Act & Assert - Add friend
      viewModel.toggleFriendSelection(friend);
      expect(viewModel.selectedFriends.contains(friend), isTrue);

      // Act & Assert - Remove friend
      viewModel.toggleFriendSelection(friend);
      expect(viewModel.selectedFriends.contains(friend), isFalse);
    });

    test('isExistingParticipant identifies existing participants', () async {
      // Arrange
      final existingParticipant = testFriends.first;
      testSharedHabit.participantData.add(
        ParticipantData(
          user: existingParticipant,
          fullCompletionCount: 0,
          currentCompletions: 0,
          lastSeen: DateTime.now(),
        ),
      );
      when(mockFriendsService.getFriends()).thenAnswer((_) async => testFriends);
      await viewModel.init(testSharedHabit);

      // Act & Assert
      expect(viewModel.isExistingParticipant(existingParticipant), isTrue);
      expect(viewModel.isExistingParticipant(testFriends[1]), isFalse);
    });

    test('sendInvitations updates shared habit with new participants', () async {
      // Arrange
      when(mockFriendsService.getFriends()).thenAnswer((_) async => testFriends);
      await viewModel.init(testSharedHabit);
      final friend = testFriends.first;
      viewModel.toggleFriendSelection(friend);

      // Act
      await viewModel.sendInvitations();

      // Assert
      verify(mockSharedHabitsService.updateSharedHabit(any)).called(1);
      verify(mockNavigationService.back(result: any)).called(1);
    });

    test('sendInvitations does nothing when no friends selected', () async {
      // Arrange
      when(mockFriendsService.getFriends()).thenAnswer((_) async => testFriends);
      await viewModel.init(testSharedHabit);

      // Act
      await viewModel.sendInvitations();

      // Assert
      verifyNever(mockSharedHabitsService.updateSharedHabit(any));
      verifyNever(mockNavigationService.back(result: any));
    });
  });
}
