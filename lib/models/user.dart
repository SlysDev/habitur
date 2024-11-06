import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 4)
class UserModel {
  @HiveField(0)
  String username;

  @HiveField(1)
  String bio;

  @HiveField(2)
  String email;

  @HiveField(3)
  String uid;

  @HiveField(4)
  AssetImage profilePicture;

  @HiveField(5)
  int userLevel;

  @HiveField(6)
  int userXP;

  @HiveField(7)
  bool isAdmin;

  @HiveField(8)
  List<StatPoint> stats;

  @HiveField(9)
  List<String> friends;

  @HiveField(10)
  List<FriendRequest> receivedFriendRequests;

  @HiveField(11)
  List<FriendRequest> sentFriendRequests;

  int get levelUpRequirement {
    return 100 * pow(1.5, userLevel).ceil();
  }

  UserModel({
    required this.username,
    this.bio = '',
    required this.email,
    required this.uid,
    this.profilePicture = const AssetImage('assets/images/default-profile.png'),
    required this.userLevel,
    required this.userXP,
    this.stats = const <StatPoint>[],
    this.isAdmin = false,
    this.friends = const [],
    this.receivedFriendRequests = const [],
    this.sentFriendRequests = const [],
  });

  // Factory method to create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    var statsMap = map['stats'] as Map<String, dynamic>?;

    return UserModel(
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      profilePicture: AssetImage(
          map['profilePicture'] ?? 'assets/images/default-profile.png'),
      userLevel: map['userLevel'] ?? 0,
      userXP: map['userXP'] ?? 0,
      isAdmin: map['isAdmin'] ?? false,
      // Handle 'stats' field
      stats: (statsMap?['statPoints'] as List<dynamic>?)
              ?.map((stat) => StatPoint.fromMap(stat as Map<String, dynamic>))
              .toList() ??
          <StatPoint>[],
      friends: List<String>.from(map['friends'] ?? []),
      receivedFriendRequests: (map['receivedFriendRequests'] as List<dynamic>?)
              ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
              .toList() ??
          [],
      sentFriendRequests: (map['sentFriendRequests'] as List<dynamic>?)
              ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'UserModel(username: $username, bio: $bio, email: $email, uid: $uid, profilePicture: $profilePicture, userLevel: $userLevel, userXP: $userXP, isAdmin: $isAdmin, stats: $stats, friends: $friends, receivedFriendRequests: $receivedFriendRequests, sentFriendRequests: $sentFriendRequests)';
  }
}
