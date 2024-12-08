import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';

class SharedHabitsService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();
  final _userService = locator<UserService>();

  List<SharedHabit> _sharedHabits = [];
  List<SharedHabit> get sharedHabits => _sharedHabits;

  SharedHabitsService() {
    listenToReactiveValues([]);
  }

  Future<List<SharedHabit>> getSharedHabits() async {
    try {
      final userId = _userService.currentUser?.uid;
      if (userId == null) return [];

      // Get shared habits where the current user is a participant
      final sharedHabitsData = await _databaseService.getSharedHabits(userId);
      _sharedHabits = sharedHabitsData;
      
      notifyListeners();
      return _sharedHabits;
    } catch (e) {
      // Log error and return empty list
      print('Error fetching shared habits: $e');
      return [];
    }
  }

  Future<void> createSharedHabit(SharedHabit sharedHabit) async {
    try {
      // Add current user as a participant if not already included
      final currentUser = _userService.currentUser;
      if (currentUser != null) {
        final isParticipant = sharedHabit.participantData
            .any((participant) => participant.user.uid == currentUser.uid);
            
        if (!isParticipant) {
          sharedHabit.participantData.add(
            ParticipantData(
              user: currentUser,
              fullCompletionCount: 0,
              lastSeen: DateTime.now(),
            ),
          );
        }
      }

      // Save to database
      await _databaseService.createSharedHabit(sharedHabit);
      
      // Update local list
      _sharedHabits.add(sharedHabit);
      notifyListeners();
    } catch (e) {
      // Log error and rethrow
      print('Error creating shared habit: $e');
      rethrow;
    }
  }

  Future<void> updateSharedHabit(SharedHabit sharedHabit) async {
    try {
      // Update in database
      await _databaseService.updateSharedHabit(sharedHabit);
      
      // Update local list
      final index = _sharedHabits.indexWhere((h) => h.id == sharedHabit.id);
      if (index != -1) {
        _sharedHabits[index] = sharedHabit;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating shared habit: $e');
      rethrow;
    }
  }

  Future<void> deleteSharedHabit(int habitId) async {
    try {
      // Delete from database
      await _databaseService.deleteSharedHabit(habitId);
      
      // Remove from local list
      _sharedHabits.removeWhere((h) => h.id == habitId);
      notifyListeners();
    } catch (e) {
      print('Error deleting shared habit: $e');
      rethrow;
    }
  }

  Future<void> updateParticipantProgress(
    SharedHabit sharedHabit,
    String userId,
    int completions,
  ) async {
    try {
      final participantIndex = sharedHabit.participantData
          .indexWhere((p) => p.user.uid == userId);
          
      if (participantIndex != -1) {
        // Update participant data
        sharedHabit.participantData[participantIndex].currentCompletions = completions;
        sharedHabit.participantData[participantIndex].lastSeen = DateTime.now();
        
        if (completions >= sharedHabit.habit.targetGoal) {
          sharedHabit.participantData[participantIndex].fullCompletionCount++;
        }
        
        // Save changes
        await updateSharedHabit(sharedHabit);
      }
    } catch (e) {
      print('Error updating participant progress: $e');
      rethrow;
    }
  }
}
