import 'dart:math';

import 'package:flutter/material.dart';
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
    );
  }
}
