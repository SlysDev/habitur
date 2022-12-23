import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class Database extends ChangeNotifier {
  CollectionReference users = _firestore.collection('users');
  Future<void> userSetup(String username, String email) async {
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid); // create a new doc w/ uid.
    userDoc.set({
      'username': username,
      'email': email,
      'uid': uid,
      'habits': [],
    });
    return;
  }

  get userData {
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    return userDoc;
  }

  get currentUser {
    return _auth.currentUser;
  }

  void addHabit(Habit habit) {
    users.doc(_auth.currentUser!.uid.toString()).collection('habits').add({
      'title': habit.title,
      'category': habit.category,
      'streak': 0,
    });
  }

  void uploadHabits() {
    //// TODO: Upload hive's storage of the habit list to Firebase  <22-12-22, slys> //
  }
}
