import 'package:flutter/foundation.dart';
import 'package:habitur/models/user.dart';

class UserData extends ChangeNotifier {
  int levelUpRequirement = 100;
  User currentUser = User(
      username: 'User', userXP: 0, userLevel: 1, uid: 'N/A', email: 'user');
  void addHabiturRating({int amount = 10}) {
    currentUser.userXP += amount;
    checkLevelUp();
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
