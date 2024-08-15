import 'package:flutter/foundation.dart';
import 'package:habitur/models/user.dart';

class UserData extends ChangeNotifier {
  int levelUpRequirement = 100;
  UserModel currentUser = UserModel(
      username: 'User', userXP: 0, userLevel: 1, uid: 'N/A', email: 'user');
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
