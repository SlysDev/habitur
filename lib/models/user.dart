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
  bool isBlocked;

  @HiveField(14)
  DateTime? blockedAt;

  @HiveField(15)
  String? blockReason;

  @HiveField(16)
  PrivacySettings privacySettings;

  int get levelUpRequirement {
    return 100 * pow(1.5, userLevel).ceil();
  }

  UserModel({
    required this.username,
    required this.email,
    required this.uid,
    this.bio = '',
    this.userLevel = 1,
    this.userXP = 0,
    this.isAdmin = false,
    this.stats = const [],
    this.friends = const [],
    this.receivedFriendRequests = const [],
    this.sentFriendRequests = const [],
    this.profilePicture,
    this.habitVisibilitySettings = const [],
    this.isBlocked = false,
    this.blockedAt,
    this.blockReason,
    this.privacySettings = const PrivacySettings(),
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    debugPrint('UserModel.fromMap: Converting map to UserModel');
    debugPrint('Stats data: ${map['stats']}');

    List<StatPoint> statPoints = [];
    if (map['stats'] != null && map['stats'] is Map) {
      var statsMap = map['stats'] as Map<String, dynamic>;
      if (statsMap['statPoints'] != null) {
        try {
          statPoints = List<StatPoint>.from(
              statsMap['statPoints'].map((x) => StatPoint.fromMap(x)));
          debugPrint('Successfully converted ${statPoints.length} stat points');
        } catch (e) {
          debugPrint('Error converting stat points: $e');
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
      friends: map['friends'] != null ? List<String>.from(map['friends']) : [],
      receivedFriendRequests: map['receivedFriendRequests'] != null
          ? List<FriendRequest>.from(map['receivedFriendRequests']
              ?.map((x) => FriendRequest.fromMap(x)))
          : [],
      sentFriendRequests: map['sentFriendRequests'] != null
          ? List<FriendRequest>.from(
              map['sentFriendRequests']?.map((x) => FriendRequest.fromMap(x)))
          : [],
      profilePicture: map['profilePicture'],
      habitVisibilitySettings: map['habitVisibilitySettings'] != null
          ? List<HabitVisibility>.from(map['habitVisibilitySettings']
              ?.map((x) => HabitVisibility.fromMap(x)))
          : [],
      isBlocked: map['isBlocked'] ?? false,
      blockedAt:
          map['blockedAt'] != null ? DateTime.parse(map['blockedAt']) : null,
      blockReason: map['blockReason'],
      privacySettings: map['privacySettings'] != null
          ? PrivacySettings.fromMap(map['privacySettings'])
          : const PrivacySettings(),
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
      'receivedFriendRequests':
          receivedFriendRequests?.map((x) => x.toMap()).toList(),
      'sentFriendRequests': sentFriendRequests?.map((x) => x.toMap()).toList(),
      'profilePicture': profilePicture,
      'habitVisibilitySettings':
          habitVisibilitySettings?.map((x) => x.toMap()).toList(),
      'isBlocked': isBlocked,
      'blockedAt': blockedAt?.toIso8601String(),
      'blockReason': blockReason,
      'privacySettings': privacySettings.toMap(),
    };
  }

  @override
  String toString() {
    return 'UserModel(username: $username, bio: $bio, email: $email, uid: $uid, profilePicture: $profilePicture, userLevel: $userLevel, userXP: $userXP, isAdmin: $isAdmin, stats: $stats, friends: $friends, receivedFriendRequests: $receivedFriendRequests, sentFriendRequests: $sentFriendRequests, habitVisibilitySettings: $habitVisibilitySettings, isBlocked: $isBlocked, blockedAt: $blockedAt, blockReason: $blockReason, privacySettings: $privacySettings)';
  }

  UserModel copyWith({
    String? username,
    String? bio,
    String? email,
    String? uid,
    int? userLevel,
    int? userXP,
    bool? isAdmin,
    List<StatPoint>? stats,
    List<String>? friends,
    List<FriendRequest>? receivedFriendRequests,
    List<FriendRequest>? sentFriendRequests,
    String? profilePicture,
    List<HabitVisibility>? habitVisibilitySettings,
    bool? isBlocked,
    DateTime? blockedAt,
    String? blockReason,
    PrivacySettings? privacySettings,
  }) {
    return UserModel(
      username: username ?? this.username,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      userLevel: userLevel ?? this.userLevel,
      userXP: userXP ?? this.userXP,
      isAdmin: isAdmin ?? this.isAdmin,
      stats: stats ?? this.stats,
      friends: friends ?? this.friends,
      receivedFriendRequests:
          receivedFriendRequests ?? this.receivedFriendRequests,
      sentFriendRequests: sentFriendRequests ?? this.sentFriendRequests,
      profilePicture: profilePicture ?? this.profilePicture,
      habitVisibilitySettings:
          habitVisibilitySettings ?? this.habitVisibilitySettings,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedAt: blockedAt ?? this.blockedAt,
      blockReason: blockReason ?? this.blockReason,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }
}
