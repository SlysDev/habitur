import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';
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
  AssetImage profilePicture;
  @HiveField(5)
  int userLevel;
  @HiveField(6)
  int userXP;
  // int userFollowers; (may use, need to reassess SM func.)
  List<Habit> habits = []; // only contain those that are marked private
  @HiveField(7)
  bool isAdmin;
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
    this.habits = const [],
    this.isAdmin = false,
    // this.userFollowers = 0,
  });
}
