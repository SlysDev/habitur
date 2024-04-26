import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';

class CommunityChallenge extends SharedHabit {
  String description;
  int id;
  DateTime startDate;
  DateTime endDate;
  int requiredFullCompletions;
  int currentFullCompletions = 0;
  List<ParticipantData> participantDataList = [];

  void checkFullCompletion() {
    if (habit.isCompleted == true) {
      currentFullCompletions++;
    }
  }

  void decrementFullCompletion() {
    currentFullCompletions--;
  }

  List<ParticipantData> getSortedParticipantData() {
    List<ParticipantData> sortedParticipantData = participantDataList;
    sortedParticipantData
        .sort((a, b) => b.completionCount.compareTo(a.completionCount));
    return sortedParticipantData;
  }

  List<ParticipantData> getTopThreeParticipants() {
    List<ParticipantData> sortedParticipantData = getSortedParticipantData();
    return sortedParticipantData.sublist(0, 3);
  }

  void addParticipantData(ParticipantData newParticipantData) {
    if (participantDataList
        .where((element) => element.user.uid == newParticipantData.user.uid)
        .isEmpty) {
      participantDataList.add(newParticipantData);
    } else {
      participantDataList
          .firstWhere(
              (element) => element.user.uid == newParticipantData.user.uid)
          .completionCount += newParticipantData.completionCount;
    }
    participantDataList.add(newParticipantData);
  }

  void decrementParticipantData(User user) {
    if (participantDataList
        .where((element) => element.user.uid == user.uid)
        .isNotEmpty) {
      if (participantDataList
              .firstWhere((element) => element.user.uid == user.uid)
              .completionCount ==
          0) {
        participantDataList
            .removeWhere((element) => element.user.uid == user.uid);
      } else {
        participantDataList
            .firstWhere((element) => element.user.uid == user.uid)
            .completionCount--;
      }
    } else {
      print('User not found in participantDataList');
    }
  }

  CommunityChallenge({
    required this.description,
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.requiredFullCompletions,
    this.currentFullCompletions = 0,
    required Habit habit,
  }) : super(
          description: description,
          id: id,
          startDate: startDate,
          endDate: endDate,
          participantData: [], // Empty list for participants
          creators: [], // Empty list for creators
          habit: habit,
        );
}
