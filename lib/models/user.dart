import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';

class User {
  String username;
  String description;
  String email;
  String uid;
  AssetImage profilePicture;
  int userLevel;
  int userXP;
  // int userFollowers; (may use, need to reassess SM func.)
  List<Habit> habits = []; // only contain those that are marked private
  User({
    required this.username,
    this.description = '',
    required this.email,
    required this.uid,
    this.profilePicture =
        const AssetImage('add default profile picture asset here'),
    required this.userLevel,
    required this.userXP,
    this.habits = const [],
    // this.userFollowers = 0,
  });
}
