import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/services/community_service.dart';

class CommunityHabitListViewModel
    extends StreamViewModel<List<CommunityChallenge>> {
  final _communityService = locator<CommunityService>();

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  @override
  Stream<List<CommunityChallenge>> get stream =>
      _communityService.challengesStream;

  List<CommunityChallenge> get challenges => data ?? [];

  void initialize(bool isAdmin) async {
    _isAdmin = isAdmin;
    await resetCurrentUserCurrentCompletions();
  }

  Future<void> refreshChallenges() async {
    await resetCurrentUserCurrentCompletions();
    notifySourceChanged();
  }

  Future<void> resetCurrentUserCurrentCompletions() async {
    for (CommunityChallenge challenge in challenges) {
      await _communityService
          .resetCurrentUserCurrentCompletions(challenge.id.toString());
    }
    notifySourceChanged();
  }
}
