import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';

class ReceivedFriendRequestsListModel
    extends StreamViewModel<List<FriendRequest>> {
  final _friendsService = locator<FriendsService>();

  List<FriendRequest> get receivedRequests => data ?? [];

  @override
  Stream<List<FriendRequest>> get stream =>
      _friendsService.receivedRequestsStream;
}
