import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:timeago/timeago.dart' as timeago;

class SentFriendRequestCardModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final _friendsService = locator<FriendsService>();
  final _dialogService = locator<DialogService>();

  late FriendRequest _request;

  UserModel? _recipient;

  UserModel? get recipient => _recipient;

  String get relativeDate {
    return timeago.format(_request.dateSent);
  }

  Future<void> initialize(FriendRequest request) async {
    _request = request;
    _recipient = await _userService.getUserById(_request.recipientUid);
  }

  Future<void> cancelFriendRequest() {
    return _friendsService.cancelFriendRequest(_request);
  }

  void showProfileDialog() {
    _dialogService.showCustomDialog(variant: DialogType.profile, data: {
      'uid': _recipient!.uid,
      'isFriendProfile': true,
      'isFriend': true,
    });
  }
}
