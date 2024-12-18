import 'dart:async';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';

class ReceivedFriendRequestsViewModel
    extends StreamViewModel<List<FriendRequest>> {
  final _friendsService = locator<FriendsService>();
  final _userService = locator<UserService>();

  // Map to store sender user models
  final Map<String, UserModel> _requestSenders = {};
  Map<String, UserModel> get requestSenders => _requestSenders;

  List<FriendRequest> get friendRequests => data ?? [];

  @override
  Stream<List<FriendRequest>> get stream =>
      _friendsService.receivedRequestsStream;

  @override
  void onData(List<FriendRequest>? data) {
    super.onData(data);
    if (data != null) {
      _loadRequestSenders(data);
    }
  }

  Future<void> _loadRequestSenders(List<FriendRequest> requests) async {
    for (final request in requests) {
      if (!_requestSenders.containsKey(request.senderUid)) {
        try {
          final sender = await _userService.getUserById(request.senderUid);
          if (sender != null) {
            _requestSenders[request.senderUid] = sender;
            notifyListeners();
          }
        } catch (e) {
          // Handle error silently, UI will show placeholder for failed loads
        }
      }
    }
  }

  Future<void> acceptRequest(FriendRequest request) async {
    setBusy(true);
    try {
      await _friendsService.acceptFriendRequest(request);
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> declineRequest(FriendRequest request) async {
    setBusy(true);
    try {
      await _friendsService.declineFriendRequest(request);
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }
}
