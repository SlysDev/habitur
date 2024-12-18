import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/services/community_service.dart';

class CommunityHabitListViewModel extends BaseViewModel {
  final _communityService = locator<CommunityService>();

  List<CommunityChallenge> _challenges = [];
  List<CommunityChallenge> get challenges => _challenges;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  void initialize(bool isAdmin) {
    _isAdmin = isAdmin;
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    try {
      setBusy(true);
      _challenges = _communityService.getActiveChallenges();
      notifyListeners();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> refreshChallenges() async {
    try {
      await _communityService.loadChallenges();
      await _loadChallenges();
    } catch (e) {
      setError(e);
    }
  }
}
