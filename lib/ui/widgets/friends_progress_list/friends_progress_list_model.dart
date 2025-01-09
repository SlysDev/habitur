import 'package:flutter/foundation.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:stacked/stacked.dart';

class FriendsProgressListModel extends FutureViewModel<List<ParticipantData>> {
  final _friendsService = locator<FriendsService>();

  final List<ParticipantData> participants;
  final double targetGoal;

  FriendsProgressListModel({
    required this.participants,
    required this.targetGoal,
  });

  List<ParticipantData> get friendsProgress => data ?? [];

  @override
  Future<List<ParticipantData>> futureToRun() async {
    if (participants.isEmpty) {
      debugPrint('No participants to load');
      return [];
    }

    final filteredParticipants = await Future.wait(
      participants.map((participant) async {
        final isFriend = await _friendsService.isFriend(participant.userId);
        return isFriend ? participant : null;
      }),
    );

    return filteredParticipants
        .where((participant) => participant != null)
        .cast<ParticipantData>()
        .toList();
  }
}
