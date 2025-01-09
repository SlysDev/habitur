import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/services/friends_service.dart';

class ProfileDrawerButtonModel extends BaseViewModel {
  final _friendsService = locator<FriendsService>();
  bool hasNewFriendRequests = false;

  ProfileDrawerButtonModel() {
    _checkForNewFriendRequests();
  }

  void _checkForNewFriendRequests() {
    _friendsService.receivedRequestsStream.listen((requests) {
      hasNewFriendRequests = requests.any((request) => !request.isAccepted);
      notifyListeners();
    });
  }

  void setNewFriendRequests(bool hasNewRequests) {
    hasNewFriendRequests = hasNewRequests;
    notifyListeners();
  }
}
