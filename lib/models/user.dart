import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/habit_visibility.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 4)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String bio;

  @HiveField(2)
  String email;

  @HiveField(3)
  String uid;

  @HiveField(4)
  int userLevel;

  @HiveField(5)
  int userXP;

  @HiveField(6)
  bool isAdmin;

  @HiveField(7)
  List<StatPoint> stats;

  @HiveField(8)
  List<String> friends;

  @HiveField(9)
  List<FriendRequest> receivedFriendRequests;

  @HiveField(10)
  List<FriendRequest> sentFriendRequests;

  @HiveField(11)
  String? profilePicture;

  @HiveField(12)
  List<HabitVisibility> habitVisibilitySettings;

  @HiveField(13)
  PrivacySettings? privacySettings;

  int get levelUpRequirement {
    return 100 * pow(1.5, userLevel).ceil();
  }

  UserModel({
    required this.username,
    this.bio = '',
    required this.email,
    required this.uid,
    this.userLevel = 1,
    this.userXP = 0,
    this.isAdmin = false,
    this.profilePicture,
    List<StatPoint>? stats,
    List<String>? friends,
    List<FriendRequest>? receivedFriendRequests,
    List<FriendRequest>? sentFriendRequests,
    List<HabitVisibility>? habitVisibilitySettings,
    this.privacySettings,
  })  : this.stats = stats ?? [],
        this.friends = friends ?? [],
        this.receivedFriendRequests = receivedFriendRequests ?? [],
        this.sentFriendRequests = sentFriendRequests ?? [],
        this.habitVisibilitySettings = habitVisibilitySettings ?? [];

  factory UserModel.fromMap(Map<String, dynamic> map) {
    debugPrint('UserModel.fromMap: Converting map to UserModel');
    debugPrint('Stats data: ${map['stats']}');
    
    List<StatPoint>? statPoints;
    if (map['stats'] != null && map['stats'] is Map) {
      var statsMap = map['stats'] as Map<String, dynamic>;
      if (statsMap['statPoints'] != null) {
        try {
          statPoints = List<StatPoint>.from(
            statsMap['statPoints'].map((x) => StatPoint.fromMap(x))
          );
          debugPrint('Successfully converted ${statPoints.length} stat points');
        } catch (e) {
          debugPrint('Error converting stat points: $e');
          statPoints = [];
        }
      }
    }

    return UserModel(
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      userLevel: map['userLevel']?.toInt() ?? 0,
      userXP: map['userXP']?.toInt() ?? 0,
      isAdmin: map['isAdmin'] ?? false,
      stats: statPoints,
      friends: map['friends'] != null
          ? List<String>.from(map['friends'])
          : null,
      receivedFriendRequests: map['receivedFriendRequests'] != null
          ? List<FriendRequest>.from(
              map['receivedFriendRequests']?.map((x) => FriendRequest.fromMap(x)))
          : null,
      sentFriendRequests: map['sentFriendRequests'] != null
          ? List<FriendRequest>.from(
              map['sentFriendRequests']?.map((x) => FriendRequest.fromMap(x)))
          : null,
      profilePicture: map['profilePicture'],
      habitVisibilitySettings: map['habitVisibilitySettings'] != null
          ? List<HabitVisibility>.from(
              map['habitVisibilitySettings']
                  ?.map((x) => HabitVisibility.fromMap(x)))
          : null,
      privacySettings: map['privacySettings'] != null
          ? PrivacySettings.fromMap(map['privacySettings'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'bio': bio,
      'email': email,
      'uid': uid,
      'userLevel': userLevel,
      'userXP': userXP,
      'isAdmin': isAdmin,
      'stats': stats?.map((x) => x.toMap()).toList(),
      'friends': friends,
      'receivedFriendRequests': receivedFriendRequests?.map((x) => x.toMap()).toList(),
      'sentFriendRequests': sentFriendRequests?.map((x) => x.toMap()).toList(),
      'profilePicture': profilePicture,
      'habitVisibilitySettings': habitVisibilitySettings?.map((x) => x.toMap()).toList(),
      'privacySettings': privacySettings?.toMap(),
    };
  }

  @override
  String toString() {
    return 'UserModel(username: $username, bio: $bio, email: $email, uid: $uid, profilePicture: $profilePicture, userLevel: $userLevel, userXP: $userXP, isAdmin: $isAdmin, stats: $stats, friends: $friends, receivedFriendRequests: $receivedFriendRequests, sentFriendRequests: $sentFriendRequests, habitVisibilitySettings: $habitVisibilitySettings, privacySettings: $privacySettings)';
  }
}
