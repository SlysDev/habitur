import 'package:flutter/material.dart';
import 'package:habitur/app/app.dialogs.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileDrawerModel extends StreamViewModel {
  final _authService = locator<AuthService>();
  final _userService = locator<UserService>();
  final _friendsService = locator<FriendsService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  @override
  Stream<UserModel?> get stream => _userService.userStream;

  UserModel? get currentUser => data;

  // late UserModel _currentUser;
  // UserModel get currentUser => _currentUser;

  bool get hasEmail =>
      currentUser?.email != null && currentUser!.email.isNotEmpty;
  bool get hasBio => currentUser?.bio != null && currentUser!.bio.isNotEmpty;

  Future<void> initialize() async {}

  Future<void> sendFriendRequest(String username) async {
    setBusy(true);
    try {
      await _friendsService.sendFriendRequestByUsername(username);
      notifyListeners();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void navigateToSettings() {
    _navigationService.navigateToSettingsView();
  }

  void showProfileDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.profile,
      data: {'uid': currentUser?.uid ?? '', 'isFriendProfile': false},
    );
  }

  String get uid => _authService.currentUser?.uid ?? '';
}
