import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileDrawerModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _userService = locator<UserService>();
  final _friendsService = locator<FriendsService>();
  final _dialogService = locator<DialogService>();

  late UserModel _currentUser;
  UserModel get currentUser => _currentUser;

  bool get hasEmail =>
      _currentUser.email != null && _currentUser.email!.isNotEmpty;
  bool get hasBio => _currentUser.bio != null && _currentUser.bio!.isNotEmpty;

  Future<void> initialize() async {
    setBusy(true);
    try {
      UserModel? user = await _userService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
      notifyListeners();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> sendFriendRequest(String username, BuildContext context) async {
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

  void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void showProfileDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.profile,
      data: {'user': _currentUser, 'isFriendProfile': false},
    );
  }

  String get uid => _authService.currentUser?.uid ?? '';
}
