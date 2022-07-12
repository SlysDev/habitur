import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';
import 'package:flutter/foundation.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class UserData extends ChangeNotifier {
  CollectionReference users = _firestore.collection('users');
  final user = _auth.currentUser;
  late DocumentReference userDoc;
  final List<Habit> _userHabits = [];
  int habiturRating = 100;
  void updateUserData() {
    notifyListeners();
  }

  void addUserHabit(Habit habit) {
    _userHabits.add(habit);
    notifyListeners();
  }

  void removeUserHabit(int index) {
    _userHabits.removeAt(index);
    notifyListeners();
  }

  UnmodifiableListView<Habit> get userHabits {
    return UnmodifiableListView(_userHabits);
  }
}
