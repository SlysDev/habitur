import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class HomeGreetingHeaderModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final DateTime _currentTime = DateTime.now();

  String? _username;
  String get username => _username ?? '';

  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';

  int? _level;
  int get level => _level ?? 1;

  double? _xpProgress;
  double get xpProgress => _xpProgress ?? 0.0;

  int? _streak;
  int get streak => _streak ?? 0;

  String get timeOfDay => getTimeSlot(_currentTime);

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
      rebuildUi();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }
}
