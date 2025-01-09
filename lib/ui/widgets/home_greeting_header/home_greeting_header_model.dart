import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class HomeGreetingHeaderModel extends StreamViewModel {
  final _userService = locator<UserService>();

  @override
  Stream<UserModel?> get stream => _userService.userStream;

  UserModel? get user => data ?? null;

  final DateTime _currentTime = DateTime.now();

  String get username => user?.username ?? '';

  String get photoUrl => user?.profilePicture ?? '';

  int get level => user?.userLevel ?? 1;

  double get xpProgress =>
      ((user?.userXP ?? 0) / (user?.levelUpRequirement ?? 1)).toDouble();

  int get streak => user == null
      ? 0
      : user!.stats.isEmpty
          ? 0
          : user!.stats.last.streak;

  String get timeOfDay => getTimeSlot(_currentTime);

  String get formattedDate {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d').format(now);
  }
}
