import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:stacked/stacked.dart';

class SentFriendRequestsListModel extends StreamViewModel {
  final _friendsService = locator<FriendsService>();
  @override
  Stream<List<FriendRequest>> get stream => _friendsService.sentRequestsStream;

  List<FriendRequest> get sentRequests => data ?? [];
}
