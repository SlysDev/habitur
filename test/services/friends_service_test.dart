import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FriendsServiceTest -', () {
    late FriendsService friendsService;

    setUp(() {
      registerServices();
      friendsService = FriendsService();
    });

    tearDown(() => locator.reset());

    group('Friend List Operations -', () {
      test('friendsStream should return empty list when user has no friends',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test('friendsStream should return list of friend UIDs', () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });
    });

    group('Friend Request Operations -', () {
      test('sendFriendRequest should create request in both users documents',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test('sendFriendRequestByUsername should find user and send request',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test('sendFriendRequestByUsername should throw if username is empty',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test('sendFriendRequestByUsername should throw if user not found',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test('acceptFriendRequest should update both users documents', () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test(
          'declineFriendRequest should remove request from both users documents',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test(
          'cancelFriendRequest should remove request from both users documents',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });
    });

    group('Friend Data Operations -', () {
      test('getFriendVisibleHabits should return only public habits', () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test('getFriendVisibleHabits should throw if friend not found', () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });
    });

    group('Request Streams -', () {
      test('receivedRequestsStream should return list of received requests',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test('sentRequestsStream should return list of sent requests', () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });
    });

    group('Error Handling -', () {
      test('_getUserDocById should return null for non-existent user',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });

      test('operations should throw appropriate errors for invalid states',
          () async {
        // TODO: Implement test once Firebase Test Utils are set up
      });
    });
  });
}
