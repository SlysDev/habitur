import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/activity_type.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/activity_service.dart';
import 'package:habitur/services/activity_database_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

// Generate mocks using mockito
class MockActivityDatabaseService extends Mock
    implements ActivityDatabaseService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  group('ActivityServiceTest -', () {
    late ActivityService sut; // system under test
    late MockActivityDatabaseService mockActivityDatabaseService;
    late MockLocalStorageService mockLocalStorageService;

    setUp(() async {
      // Register services
      setupLocator();

      // Initialize mocks
      mockActivityDatabaseService = MockActivityDatabaseService();
      mockLocalStorageService = MockLocalStorageService();

      // Replace real services with mocks in the locator
      locator.registerSingleton<ActivityDatabaseService>(
          mockActivityDatabaseService);
      locator.registerSingleton<LocalStorageService>(mockLocalStorageService);

      // Create the service with mocked dependencies
      sut = ActivityService();
    });

    tearDown(() => locator.reset());

    group('getActivity -', () {
      test('should return null when user is not logged in', () async {
        // Arrange
        when(mockLocalStorageService.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await sut.getActivity('test-activity-id');

        // Assert
        expect(result, isNull);
        verify(mockLocalStorageService.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockActivityDatabaseService);
      });

      test('should return activity when user is logged in', () async {
        // Arrange
        final testUser = UserModel(
            username: 'test-user',
            email: 'test@example.com',
            uid: 'test-user-id');
        final testActivity = ActivityEvent(
          username: 'test-user',
          habitId: 'test-habit-id',
          habitTitle: 'test-habit-title',
          id: 'test-activity-id',
          userId: 'test-user-id',
          type: ActivityType.habitProgress,
          timestamp: DateTime.now(),
        );

        when(mockLocalStorageService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockActivityDatabaseService.getActivity(
                'test-activity-id', 'test-user-id'))
            .thenAnswer((_) async => testActivity);

        // Act
        final result = await sut.getActivity('test-activity-id');

        // Assert
        expect(result, equals(testActivity));
        verify(mockLocalStorageService.getCurrentUser()).called(1);
        verify(mockActivityDatabaseService.getActivity(
                'test-activity-id', 'test-user-id'))
            .called(1);
      });
    });
  });
}
