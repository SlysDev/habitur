import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReceivedFriendRequestCardModel extends BaseViewModel {
  final _friendsService = locator<FriendsService>();
  final _userService = locator<UserService>();

  UserModel? _sender;
  UserModel? get sender => _sender;

  Future<void> init(FriendRequest request) async {
    _sender = await _userService.getUserById(request.senderUid);
    notifyListeners();
  }

  Future<void> acceptFriendRequest(FriendRequest request) async {
    setBusy(true);
    await _friendsService.acceptFriendRequest(request);
    setBusy(false);
  }

  Future<void> declineFriendRequest(FriendRequest request) async {
    setBusy(true);
    await _friendsService.declineFriendRequest(request);
    setBusy(false);
  }

  String getRelativeTime(DateTime date) {
    return timeago.format(date);
  }
}
