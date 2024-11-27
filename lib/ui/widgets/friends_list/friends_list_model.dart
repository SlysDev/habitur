import 'package:habitur/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/user_service.dart';

class FriendsListModel extends StreamViewModel<List<String>> {
  final _friendsService = locator<FriendsService>();
  final _userService = locator<UserService>();

  Map<String, UserModel?> _friendUsers = {};
  Map<String, UserModel?> get friendUsers => _friendUsers;

  @override
  Stream<List<String>> get stream => _friendsService.friendsStream;

  Future<UserModel?> getFriendUser(String friendUid) async {
    if (!_friendUsers.containsKey(friendUid)) {
      _friendUsers[friendUid] = await _userService.getUserById(friendUid);
      notifyListeners();
    }
    return _friendUsers[friendUid];
  }

  void showFriendProfile(String friendUid) {
    // Navigation will be handled by the view since it requires BuildContext
  }

  @override
  void onError(error) {
    setError(error);
  }
}
