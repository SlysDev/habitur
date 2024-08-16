import 'package:flutter/foundation.dart';
import 'package:habitur/models/user.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserLocalStorage extends ChangeNotifier {
  dynamic _userBox;

  Future<void> init() async {
    if (Hive.isBoxOpen('user')) {
      print('userBox is open');
      _userBox = Hive.box<UserModel>('user');
    } else {
      print('userBox must be newly opened');
      _userBox = await Hive.openBox<UserModel>('user');
    }
  }

  Future<void> loadData(BuildContext context) async {
    await init(); // may need, may not
    print('initing worked w/ user LS');
    if (_userBox.values.toList().isNotEmpty) {
      Provider.of<UserLocalStorage>(context, listen: false).currentUser =
          _userBox.get(0);
      print('did we do this?');
    } else {
      Provider.of<UserLocalStorage>(context, listen: false).currentUser =
          UserModel(
        username: 'Guest',
        email: 'N/A',
        userLevel: 1,
        userXP: 0,
        uid: 'N/A',
        profilePicture: const AssetImage('assets/images/default-profile.png'),
      );
    }
  }

  Future<void> saveData(BuildContext context) async {
    _userBox.putAt(
        0, Provider.of<UserLocalStorage>(context, listen: false).currentUser);
  }

  // TODO: Refactor to store summary stats instead of summary stats repo
  UserModel get currentUser {
    if (_userBox.values.toList().isEmpty) {
      UserModel newUser = UserModel(
        username: 'Guest',
        email: 'N/A',
        userLevel: 1,
        userXP: 0,
        uid: 'N/A',
        profilePicture: const AssetImage('assets/images/default-profile.png'),
      );
      return newUser;
    } else {
      return _userBox.get(0);
    }
  }

  set currentUser(UserModel value) {
    _userBox.put(0, value);
    notifyListeners();
  }

  void updateUserProperty(String propertyName, dynamic newValue) {
    final user = _userBox.get(0);
    final updatedUser = UserModel(
      username: propertyName == "username" ? newValue : user.username,
      email: propertyName == "email" ? newValue : user.email,
      userLevel: propertyName == "userLevel" ? newValue : user.userLevel,
      userXP: propertyName == "userXP" ? newValue : user.userXP,
      uid: propertyName == "uid" ? newValue : user.uid,
      profilePicture:
          propertyName == "profilePicture" ? newValue : user.profilePicture,
    );
    currentUser = updatedUser;
    notifyListeners();
  }

  void addHabiturRating({int amount = 10}) {
    updateUserProperty('userXP', currentUser.userXP + amount);
    checkLevelUp();
    notifyListeners();
  }

  void removeHabiturRating({int amount = 10}) {
    if (currentUser.userXP < amount) {
      levelDown();
    }
    if (currentUser.userLevel == 1 && currentUser.userXP < amount) {
      updateUserProperty('userXP', 0);
      return;
    }
    updateUserProperty('userXP', currentUser.userXP - amount);
    checkLevelUp();
    notifyListeners();
  }

  void checkLevelUp() {
    if (currentUser.userXP >= currentUser.levelUpRequirement) {
      levelUp();
    }
  }

  void levelUp() {
    updateUserProperty('userLevel', currentUser.userLevel + 1);
    currentUser.userXP = 0;
    updateUserProperty('userXP', 0);
    notifyListeners();
  }

  void levelDown() {
    if (currentUser.userLevel == 1) {
      return;
    }
    updateUserProperty('userLevel', currentUser.userLevel - 1);
    updateUserProperty('userXP', currentUser.levelUpRequirement);
  }
}
