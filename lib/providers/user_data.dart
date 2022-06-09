import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

final _auth = FirebaseAuth.instance;

class UserData extends ChangeNotifier {
  final user = _auth.currentUser;
  List<Habit> _userHabits = [
    Habit(name: 'Shower', difficulty: 0.2),
  ];
  void updateUserHabits() {
    notifyListeners();
  }

  UnmodifiableListView<Habit> get userHabits {
    return UnmodifiableListView(_userHabits);
  }
}
