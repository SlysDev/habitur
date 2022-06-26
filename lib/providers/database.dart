import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class Database extends ChangeNotifier {
  Future<void> userSetup(String username, String email) async {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid); // create a new doc w/ uid.
    userDoc.set({
      'username': username,
      'email': email,
      'uid': uid,
    });
    return;
  }

  get userData {
    String uid = _auth.currentUser!.uid.toString();
    CollectionReference users = _firestore.collection('users');
    DocumentReference userDoc = users.doc(uid);
    return userDoc;
  }

  get currentUser {
    return _auth.currentUser;
  }
}
