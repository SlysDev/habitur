import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/services/activity_service.dart';

class SocialFeedViewModel extends BaseViewModel {
  final _activityService = locator<ActivityService>();
  Stream<List<ActivityEvent>>? _activitiesStream;

  bool get isLoading => _activityService.isLoading;
  bool get hasMore => _activityService.hasMore;
  List<ActivityEvent> get activities => _activityService.activities;
  Stream<List<ActivityEvent>>? get activitiesStream => _activitiesStream;

  Future<void> loadMore() async {
    await _activityService.loadMoreActivities();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _activityService.loadInitialActivities();
    _activitiesStream = await _activityService.getActivitiesStream();
    notifyListeners();
  }
}
