import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/providers/database.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import 'package:flutter/foundation.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class UserData extends ChangeNotifier {
  CollectionReference users = _firestore.collection('users');
  final user = _auth.currentUser;
  int totalHabitsCompleted = 0;
  String username = 'User';
  final List<Habit> _userHabits = [];
  void updateUserData() {
    notifyListeners();
  }

  void addFullHabitCompletion() {
    totalHabitsCompleted++;
  }

  void removeFullHabitCompletion() {
    totalHabitsCompleted--;
  }

  UnmodifiableListView<Habit> get userHabits {
    return UnmodifiableListView(_userHabits);
  }
}
