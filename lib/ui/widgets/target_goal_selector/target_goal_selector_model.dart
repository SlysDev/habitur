import 'package:stacked/stacked.dart';

class TargetGoalSelectorModel extends BaseViewModel {
  int _targetGoal = 1;
  int get targetGoal => _targetGoal;

  String _resetPeriod = 'Daily';

  String get resetPeriodNoun {
    switch (_resetPeriod) {
      case 'Daily':
        return 'day';
      case 'Weekly':
        return 'week';
      case 'Monthly':
        return 'month';
      default:
        return 'day';
    }
  }

  void initialize(int targetGoal, String resetPeriod) {
    _targetGoal = targetGoal;
    _resetPeriod = resetPeriod;
    notifyListeners();
  }

  void adjustTargetGoal(int amount) {
    _targetGoal += amount;
    notifyListeners();
  }
}
