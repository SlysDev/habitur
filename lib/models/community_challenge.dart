import 'dart:collection';

import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:provider/provider.dart';

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

  void addParticipant(ParticipantData participantData) {
    _participantDataList.add(participantData);
  }

  void loadParticipants(List<ParticipantData> participantDataList) {
    _participantDataList = participantDataList;
  }

  void sortParticipantData() {
    _participantDataList
        .sort((a, b) => b.fullCompletionCount.compareTo(a.fullCompletionCount));
  }

  List<ParticipantData> getTopThreeParticipants() {
    sortParticipantData();
    return _participantDataList.sublist(0, 3);
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
