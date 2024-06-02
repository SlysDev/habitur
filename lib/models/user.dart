import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';

class UserModel {
  String username;
  String bio;
  String email;
  String uid;
  AssetImage profilePicture;
  int userLevel;
  int userXP;
  // int userFollowers; (may use, need to reassess SM func.)
  List<Habit> habits = []; // only contain those that are marked private
  UserModel({
    required this.username,
    this.bio = '',
    required this.email,
    required this.uid,
    this.profilePicture = const AssetImage('assets/images/default-profile.png'),
    required this.userLevel,
    required this.userXP,
    this.habits = const [],
    // this.userFollowers = 0,
  });
}
