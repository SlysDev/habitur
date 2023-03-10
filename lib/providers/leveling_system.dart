import 'package:flutter/foundation.dart';

class LevelingSystem extends ChangeNotifier {
  int userLevel = 1;
  int habiturRating = 0;
  int levelUpRequirement = 100;
  void addHabiturRating({int amount = 10}) {
    habiturRating += amount;
    checkLevelUp();
  }

  void removeHabiturRating({int amount = 10}) {
    if (habiturRating < amount) {
      levelDown();
    }
    if (userLevel == 1 && habiturRating < amount) {
      habiturRating = 0;
      return;
    }
    habiturRating -= amount;
    checkLevelUp();
  }

  void checkLevelUp() {
    if (habiturRating >= levelUpRequirement) {
      levelUp();
    }
  }

  void levelUp() {
    userLevel++;
    habiturRating = 0;
    levelUpRequirement += (levelUpRequirement * 0.5).ceil();
  }

  void levelDown() {
    if (userLevel == 1) {
      return;
    }
    userLevel--;
    levelUpRequirement -= (levelUpRequirement * 0.5).ceil();
    habiturRating = levelUpRequirement;
  }
}
