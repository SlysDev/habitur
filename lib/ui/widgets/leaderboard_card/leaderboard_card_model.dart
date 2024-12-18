import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LeaderboardCardModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _friendsService = locator<FriendsService>();
  final _userService = locator<UserService>();
  ParticipantData? participant;
  void initialize(ParticipantData participant) {
    this.participant = participant;
    notifyListeners();
  }

  Future<void> showProfileDialog() async {
    bool isFriend = await _friendsService.isFriend(participant?.userId);
    UserModel? user = await getUserById(participant?.userId ?? '');
    _dialogService.showCustomDialog(
        variant: DialogType.profile,
        data: {'user': user, 'isFriendProfile': isFriend});
  }

  Future<UserModel?> getUserById(String userId) async {
    return await _userService.getUserById(userId);
  }
}
