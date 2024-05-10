import 'dart:collection';

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
  List<ParticipantData> _participantDataList = [];

  UnmodifiableListView<ParticipantData> get participants =>
      UnmodifiableListView(
        _participantDataList,
      );

  void loadParticipants(List<ParticipantData> participantDataList) {
    _participantDataList = participantDataList;
  }

  void checkFullCompletion() {
    if (habit.isCompleted == true) {
      currentFullCompletions++;
    }
  }

  void decrementFullCompletion() {
    currentFullCompletions--;
  }

  List<ParticipantData> getSortedParticipantData() {
    List<ParticipantData> sortedParticipantData = _participantDataList;
    sortedParticipantData
        .sort((a, b) => b.completionCount.compareTo(a.completionCount));
    return sortedParticipantData;
  }

  List<ParticipantData> getTopThreeParticipants() {
    List<ParticipantData> sortedParticipantData = getSortedParticipantData();
    return sortedParticipantData.sublist(0, 3);
  }

  void addParticipantData(ParticipantData newParticipantData) {
    if (_participantDataList
        .where((element) => element.user.uid == newParticipantData.user.uid)
        .isEmpty) {
      _participantDataList.add(newParticipantData);
    } else {
      _participantDataList
          .firstWhere(
              (element) => element.user.uid == newParticipantData.user.uid)
          .completionCount += newParticipantData.completionCount;
    }
    _participantDataList.add(newParticipantData);
  }

  void decrementParticipantData(User user) {
    if (_participantDataList
        .where((element) => element.user.uid == user.uid)
        .isNotEmpty) {
      if (_participantDataList
              .firstWhere((element) => element.user.uid == user.uid)
              .completionCount ==
          0) {
        _participantDataList
            .removeWhere((element) => element.user.uid == user.uid);
      } else {
        _participantDataList
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
