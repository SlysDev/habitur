import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LeaderboardCardModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _friendsService = locator<FriendsService>();
  ParticipantData? participant;
  void initialize(ParticipantData participant) {
    this.participant = participant;
    notifyListeners();
  }

  Future<void> showProfileDialog() async {
    bool isFriend = await _friendsService.isFriend(participant?.user.uid);
    _dialogService.showCustomDialog(
        variant: DialogType.profile,
        data: {'user': participant?.user, 'isFriendProfile': isFriend});
  }
}
