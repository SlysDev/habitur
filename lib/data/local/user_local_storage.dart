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
          _userBox.getAt(0);
      print('did we do this?');
    }
  }

  Future<void> saveData(BuildContext context) async {
    _userBox.putAt(
        0, Provider.of<UserLocalStorage>(context, listen: false).currentUser);
  }

  // TODO: Refactor to store summary stats instead of summary stats repo
  int levelUpRequirement = 100;
  UserModel get currentUser {
    if (_userBox.values.toList().isEmpty) {
      return UserModel(
        username: 'Guest',
        email: 'N/A',
        userLevel: 1,
        userXP: 0,
        uid: 'N/A',
        profilePicture: const AssetImage('assets/images/default-profile.png'),
      );
    } else {
      return _userBox.getAt(0);
    }
  }

  void set currentUser(UserModel value) {
    _userBox.putAt(0, value);
    notifyListeners();
  }

  void changeUsername(String newUsername) {
    currentUser.username = newUsername;
    notifyListeners();
  }

  void changeEmail(String newEmail) {
    currentUser.email = newEmail;
    notifyListeners();
  }

  void addHabiturRating({int amount = 10}) {
    currentUser.userXP += amount;
    checkLevelUp();
    notifyListeners();
  }

  void removeHabiturRating({int amount = 10}) {
    if (currentUser.userXP < amount) {
      levelDown();
    }
    if (currentUser.userLevel == 1 && currentUser.userXP < amount) {
      currentUser.userXP = 0;
      return;
    }
    currentUser.userXP -= amount;
    checkLevelUp();
    notifyListeners();
  }

  void checkLevelUp() {
    if (currentUser.userXP >= levelUpRequirement) {
      levelUp();
    }
  }

  void levelUp() {
    currentUser.userLevel++;
    currentUser.userXP = 0;
    levelUpRequirement += (levelUpRequirement * 0.5).ceil();
    notifyListeners();
  }

  void levelDown() {
    if (currentUser.userLevel == 1) {
      return;
    }
    currentUser.userLevel--;
    levelUpRequirement -= (levelUpRequirement * 0.5).ceil();
    currentUser.userXP = levelUpRequirement;
  }
}
