import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/activity_database.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/models/user.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class ActivityProvider with ChangeNotifier {
  final UserLocalStorage userStorage;
  List<ActivityEvent> _activities = [];
  final Logger _logger = Logger('ActivityProvider');
  final ActivityDatabase _activityDb = ActivityDatabase();
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  // Scoring constants
  static const double _baseScore = 1.0;
  static const double _likeWeight = 0.5;
  static const double _commentWeight = 1.0;
  static const double _friendMultiplier = 1.5;
  static const double _timeDecayFactor = 0.1;

  // Activity type base weights
  static const Map<ActivityType, double> _activityWeights = {
    ActivityType.habitCompletion: 1.0,
    ActivityType.streakMilestone: 1.5, // Streak milestones are more significant
    ActivityType.newHabit: 1.2, // New habits are moderately significant
  };

  ActivityProvider(this.userStorage);

  List<ActivityEvent> get activities => _activities;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Stream<List<ActivityEvent>> getActivitiesStream() {
    final UserModel? user = userStorage.currentUser;
    if (user == null) return Stream.value([]);

    return _activityDb.getActivitiesStream(user.uid).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['currentUserId'] = user.uid;
        return ActivityEvent.fromMap(data);
      }).where((activity) {
        if (activity.userId == user.uid) {
          if (user.privacySettings == null ||
              !user.privacySettings!.shareActivities) return false;
          switch (activity.type) {
            case ActivityType.habitCompletion:
              return user.privacySettings?.shareHabitCompletions ?? false;
            case ActivityType.streakMilestone:
              return user.privacySettings?.shareStreakMilestones ?? false;
            case ActivityType.newHabit:
              return user.privacySettings?.shareNewHabits ?? false;
          }
        }
        return true;
      }).toList();
    });
  }

  Future<void> _loadInitial() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final user = userStorage.currentUser;
      if (user == null) return;

      _activities.clear();
      final snapshot = await _activityDb.loadInitialActivities(user.uid);

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        _activities = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['currentUserId'] = user.uid;
          return ActivityEvent.fromMap(data);
        }).toList();
        _sortActivities();
      }
    } catch (e) {
      _logger.severe('Error loading initial activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;
    _isLoading = true;

    try {
      final user = userStorage.currentUser;
      if (user == null) return;

      final snapshot =
          await _activityDb.loadMoreActivities(user.uid, _lastDocument!);

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        final newActivities = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['currentUserId'] = user.uid;
          return ActivityEvent.fromMap(data);
        }).toList();
        _activities.addAll(newActivities);
        _sortActivities();
      }
    } catch (e) {
      _logger.severe('Error loading more activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createActivity(ActivityEvent activity) async {
    final user = userStorage.currentUser;
    if (user == null) return;

    if (user.privacySettings == null || !user.privacySettings!.shareActivities) return;

    switch (activity.type) {
      case ActivityType.habitCompletion:
        if (!user.privacySettings!.shareHabitCompletions) return;
        break;
      case ActivityType.streakMilestone:
        if (!user.privacySettings!.shareStreakMilestones) return;
        break;
      case ActivityType.newHabit:
        if (!user.privacySettings?.shareNewHabits ?? false) return;
        break;
    }

    if (!user.privacySettings?.shareProfilePicture ?? false) {
      activity = activity.copyWith(profilePicture: null);
    }

    try {
      final docRef = await _activityDb.createActivity(activity);
      final newActivity = activity.copyWith(id: docRef.id);
      _activities.insert(0, newActivity);
      _sortActivities();
      notifyListeners();
    } catch (e) {
      _logger.severe('Error creating activity: $e');
    }
  }

  Future<void> likeActivity(String activityId) async {
    final user = userStorage.currentUser;
    if (user == null) return;

    try {
      await _activityDb.likeActivity(activityId, user.uid);

      final activityIndex = _activities.indexWhere((a) => a.id == activityId);
      if (activityIndex != -1) {
        final activity = _activities[activityIndex];
        _activities[activityIndex] = ActivityEvent.fromMap({
          ...activity.toMap(),
          'likes': [...activity.likes, user.uid],
          'likeCount': activity.likeCount + 1,
          'currentUserId': user.uid,
        });
        _sortActivities();
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error liking activity: $e');
    }
  }

  Future<void> unlikeActivity(String activityId) async {
    final user = userStorage.currentUser;
    if (user == null) return;

    try {
      await _activityDb.unlikeActivity(activityId, user.uid);

      final activityIndex = _activities.indexWhere((a) => a.id == activityId);
      if (activityIndex != -1) {
        final activity = _activities[activityIndex];
        _activities[activityIndex] = ActivityEvent.fromMap({
          ...activity.toMap(),
          'likes': activity.likes.where((id) => id != user.uid).toList(),
          'likeCount': activity.likeCount - 1,
          'currentUserId': user.uid,
        });
        _sortActivities();
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error unliking activity: $e');
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _activityDb.deleteActivity(activityId);
      _activities.removeWhere((a) => a.id == activityId);
      notifyListeners();
    } catch (e) {
      _logger.severe('Error deleting activity: $e');
    }
  }

  double _calculateActivityScore(ActivityEvent activity) {
    final timeDiff = DateTime.now().difference(activity.timestamp).inHours;
    final timeDecay = 1.0 / (1.0 + _timeDecayFactor * timeDiff);

    final baseWeight = _activityWeights[activity.type] ?? _baseScore;
    final likeScore = activity.likeCount * _likeWeight;
    final commentScore = activity.comments.length * _commentWeight;

    final user = userStorage.currentUser;
    final friendMultiplier = user?.friends.contains(activity.userId) ?? false
        ? _friendMultiplier
        : 1.0;

    final engagementBonus = (likeScore + commentScore) / _baseScore;

    return timeDecay * baseWeight * friendMultiplier * engagementBonus;
  }

  void _sortActivities() {
    _activities.sort((a, b) {
      final scoreA = _calculateActivityScore(a);
      final scoreB = _calculateActivityScore(b);
      return scoreB.compareTo(scoreA);
    });
  }

  Future<void> toggleReaction(String activityId, ReactionType type) async {
    try {
      final userId = userStorage.currentUser?.id;
      if (userId == null) return;

      final activityIndex = _activities.indexWhere((a) => a.id == activityId);
      if (activityIndex == -1) return;

      final activity = _activities[activityIndex];
      final reactions =
          Map<ReactionType, List<Reaction>>.from(activity.reactions);

      // Remove any existing reaction from this user
      if (activity.userReaction != null) {
        reactions[activity.userReaction]
            ?.removeWhere((r) => r.userId == userId);
      }

      // Add new reaction if it's different from the existing one
      if (activity.userReaction != type) {
        if (!reactions.containsKey(type)) {
          reactions[type] = [];
        }
        reactions[type]!.add(Reaction(userId: userId, type: type));
      }

      // Update local state
      _activities[activityIndex] = activity.copyWith(
        reactions: reactions,
        userReaction: activity.userReaction != type ? type : null,
      );
      notifyListeners();

      // Update Firestore
      await _activityDb.updateActivity(
        activityId,
        {'reactions': activity.reactions},
      );
    } catch (e, stackTrace) {
      _logger.severe('Error toggling reaction', e, stackTrace);
      rethrow;
    }
  }

  Map<ReactionType, List<Reaction>> _processReactions(
      Map<String, dynamic> data, String currentUserId) {
    final reactions = <ReactionType, List<Reaction>>{};
    final reactionData = data['reactions'] as Map<String, dynamic>?;

    if (reactionData != null) {
      reactionData.forEach((key, value) {
        final type = ReactionType.values.firstWhere(
          (e) => e.toString().split('.').last == key,
          orElse: () => ReactionType.like,
        );
        reactions[type] = (value as List)
            .map((r) => Reaction.fromMap(r as Map<String, dynamic>))
            .toList();
      });
    }
    return reactions;
  }

  ReactionType? _getUserReaction(
      Map<ReactionType, List<Reaction>> reactions, String userId) {
    for (final entry in reactions.entries) {
      if (entry.value.any((r) => r.userId == userId)) {
        return entry.key;
      }
    }
    return null;
  }
}
