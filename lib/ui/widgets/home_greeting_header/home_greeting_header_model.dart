import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class HomeGreetingHeaderModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final DateTime _currentTime = DateTime.now();

  late String _username;
  String get username => _username;

  late String _photoUrl;
  String get photoUrl => _photoUrl;

  late int _level;
  int get level => _level;

  late double _xpProgress;
  double get xpProgress => _xpProgress;

  late int _streak;
  int get streak => _streak;

  String get timeOfDay {
    final hour = _currentTime.hour;
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d').format(now);
  }

  Future<void> initialize() async {
    setBusy(true);
    try {
      UserModel? user = await _userService.getCurrentUser();
      if (user != null) {
        _username = user.username;
        _photoUrl = user.profilePicture ?? '';
        _level = user.userLevel;
        _xpProgress = user.userXP / user.levelUpRequirement;
        _streak = user.stats.last.streak;
      } else {
        _username = 'User';
        _photoUrl = '';
        _level = 1;
        _xpProgress = 0.0;
        _streak = 0;
      }
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }
}
