import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class UserDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Future<void> userSetup(String username, String email) async {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid); // create a new doc w/ uid.
    userDoc.set({
      'username': username,
      'bio': '',
      'email': email,
      'uid': uid,
      'stats': {'totalHabitsCompleted': 0, 'statPoints': []},
      'userLevel': 1,
      'userXP': 0,
      'isAdmin': false,
      'lastUpdated': DateTime.now()
    });
    return;
  }

  get userData async {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    DocumentSnapshot userSnapshot = await userDoc.get();
    return userSnapshot;
  }

  get currentUser {
    return _auth.currentUser;
  }

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  Future<void> loadUserData(context) async {
    // throw Error(); // just mocking an error
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      String uid = _auth.currentUser!.uid.toString();
      for (var user in usersSnapshot.docs) {
        if (user.get('uid') == uid) {
          print('loading user...');
          Provider.of<UserLocalStorage>(context, listen: false).currentUser =
              UserModel(
                  username: user.get('username'),
                  bio: user.get('bio'),
                  email: user.get('email'),
                  uid: user.get('uid'),
                  userLevel: user.get('userLevel'),
                  userXP: user.get('userXP'),
                  isAdmin: user.get('isAdmin'));
          Provider.of<UserLocalStorage>(context, listen: false)
              .notifyListeners();
        }
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> uploadUserData(context) async {
    Database db = Database();
    // throw Error();
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (var user in usersSnapshot.docs) {
        if (user.get('uid') ==
            Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .uid) {
          await user.reference.set({
            'username': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .username,
            'bio': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .bio,
            'email': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .email,
            'userLevel': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .userLevel,
            'userXP': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .userXP,
            'isAdmin': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .isAdmin,
            'lastUpdated': DateTime.now(),
          }, SetOptions(merge: true));
        }
        print('isAdmin: ' +
            Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .isAdmin
                .toString());
        db.syncLastUpdated(context);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }
}
