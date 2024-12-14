import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/util_functions.dart';
import 'package:logging/logging.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';
import '../enums/activity_type.dart';
import '../enums/reaction_type.dart';
import '../services/local_storage_service.dart';
import '../services/activity_database_service.dart';

class ActivityService with ListenableServiceMixin {
  final _localStorageService = locator<LocalStorageService>();
  final _activityDatabaseService = locator<ActivityDatabaseService>();
  final _logger = Logger('ActivityService');

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  List<ActivityEvent> _activities = [];
  bool _isEnabled = true;

  // Scoring constants
  static const double _baseScore = 1.0;
  static const double _likeWeight = 0.5;
  static const double _commentWeight = 1.0;
  static const double _friendMultiplier = 1.5;
  static const double _timeDecayFactor = 0.1;

  // Activity type base weights
  static const Map<ActivityType, double> _activityWeights = {
    ActivityType.habitProgress: 1.0,
    ActivityType.streakMilestone: 1.5,
    ActivityType.newHabit: 1.2,
  };

  ActivityService() {
    listenToReactiveValues([_activities]);
  }

  List<ActivityEvent> get activities => _activities;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isEnabled => _isEnabled;

  Future<ActivityEvent?> getActivity(String activityId) async {
    final user = await _localStorageService.getCurrentUser();
    if (user == null) return null;
    return _activityDatabaseService.getActivity(activityId, user.uid);
  }

  Future<Stream<List<ActivityEvent>>> getActivitiesStream() async {
    final UserModel? user = await _localStorageService.getCurrentUser();
    if (user == null) return Stream.value([]);

    return _activityDatabaseService
        .getActivitiesStream(user.uid, user.friends)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ActivityEvent.fromMap(data);
      }).where((activity) {
        // Only show activities from friends and self
        if (!user.friends.contains(activity.userId) &&
            activity.userId != user.uid) {
          return false;
        }

        // Check privacy settings for user's own activities
        if (activity.userId == user.uid) {
          // For own activities, check user's privacy settings
          if (user.privacySettings == null ||
              !user.privacySettings!.shareActivities) return false;

          switch (activity.type) {
            case ActivityType.habitProgress:
              return user.privacySettings?.shareHabitCompletions ?? false;
            case ActivityType.streakMilestone:
              return user.privacySettings?.shareStreakMilestones ?? false;
            case ActivityType.newHabit:
              return user.privacySettings?.shareNewHabits ?? false;
            case ActivityType.habitShare:
              return user.privacySettings?.shareNewHabits ?? false;
            case ActivityType.communityChallengeCompletion:
              return user.privacySettings?.shareCommunityChallengeCompletions ??
                  false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> loadInitialActivities() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _localStorageService.getCurrentUser();
      if (user != null) {
        final snapshot = await _activityDatabaseService.getInitialActivities(
            user.uid, user.friends);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMore = snapshot.docs.length >= 10;

        _activities = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ActivityEvent.fromMap(data);
        }).toList();
        await _sortActivities();
      }
    } catch (e, s) {
      _logger.severe('Error loading initial activities: $e');
      _logger.severe('Stack trace: $s');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreActivities() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _localStorageService.getCurrentUser();
      if (user != null) {
        final snapshot = await _activityDatabaseService.getMoreActivities(
          user.uid,
          user.friends,
          _lastDocument!,
        );

        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMore = snapshot.docs.length >= 10;

        final newActivities = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['currentUserId'] = user.uid;
          return ActivityEvent.fromMap(data);
        }).toList();
        _activities.addAll(newActivities);
        await _sortActivities();
      }
    } catch (e) {
      _logger.severe('Error loading more activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createActivity(ActivityEvent activity) async {
    if (_isLoading) return;

    final UserModel? user = await _localStorageService.getCurrentUser();
    if (user == null ||
        user.privacySettings == null ||
        !user.privacySettings!.shareActivities) {
      _logger.info('Not creating activity because activities are not shared');
      return;
    }

    // Check specific activity type privacy settings
    switch (activity.type) {
      case ActivityType.habitProgress:
        if (!user.privacySettings!.shareHabitCompletions) {
          _logger.info(
              'Not creating habit completion activity due to privacy settings');
          return;
        }
        break;
      case ActivityType.streakMilestone:
        if (!user.privacySettings!.shareStreakMilestones) {
          _logger.info(
              'Not creating streak milestone activity due to privacy settings');
          return;
        }
        break;
      case ActivityType.newHabit:
        if (!user.privacySettings!.shareNewHabits) {
          _logger
              .info('Not creating new habit activity due to privacy settings');
          return;
        }
        break;
      case ActivityType.habitShare:
      // TODO: Add a custom privacy setting for shared habits in the future
        if (!user.privacySettings!.shareNewHabits) {
          _logger.info(
              'Not creating habit share activity due to privacy settings');
          return;
        }
        break;
      case ActivityType.communityChallengeCompletion:
        if (!user.privacySettings!.shareCommunityChallengeCompletions) {
          _logger.info(
              'Not creating community challenge completion activity due to privacy settings');
          return;
        }
        break;
    }

    // Handle profile picture privacy
    if (user.privacySettings == null ||
        !user.privacySettings!.shareProfilePicture) {
      activity = activity.copyWith(profilePicture: null);
    }

    _isLoading = true;
    notifyListeners();

    try {
      _activities.insert(0, activity);
      await _activityDatabaseService.createActivity(activity);
      await _sortActivities();
      notifyListeners();
    } catch (e) {
      _logger.severe('Error creating activity: $e');
    }
  }

  Future<void> createActivityForEvent(String userId, String username,
      ActivityType type, String habitId, String habitTitle,
      {Map<String, dynamic>? metadata}) async {
    final activity = ActivityEvent(
      userId: userId,
      username: username,
      type: type,
      habitId: habitId,
      habitTitle: habitTitle,
      metadata: metadata,
    );

    await createActivity(activity);
  }

  Future<void> likeActivity(String activityId) async {
    debugPrint('activity_service.dart likeActivity(); activityId: $activityId');
    final activity = await getActivity(activityId);
    debugPrint(
        'activity_service.dart likeActivity(); activity user id: ${activity?.userId}');
    if (activity == null) throw Exception('Activity not found');
    try {
      final user = await _localStorageService.getCurrentUser();
      if (activity.userId == user?.uid) {
        debugPrint('You can\'t like your own activity');

        showErrorSnackbar('You can\'t like your own activity');
        return;
      }
      if (user != null && !activity.likes.contains(user.uid)) {
        await _activityDatabaseService.updateActivity(activity.id!, {
          ...activity.toMap(),
          'likes': [...activity.likes, user.uid],
          'likeCount': activity.likeCount + 1,
          'currentUserId': user.uid,
        });
        await _sortActivities();
        notifyListeners();
        showSuccessSnackbar('Liked activity');
      }
    } catch (e) {
      _logger.severe('Error liking activity: $e');
    }
  }

  Future<void> unlikeActivity(String activityId) async {
    final activity = await getActivity(activityId);
    if (activity == null) throw Exception('Activity not found');
    try {
      final user = await _localStorageService.getCurrentUser();
      if (user != null && activity.likes.contains(user.uid)) {
        await _activityDatabaseService.updateActivity(activity.id!, {
          ...activity.toMap(),
          'likes': activity.likes.where((id) => id != user.uid).toList(),
          'likeCount': activity.likeCount - 1,
          'currentUserId': user.uid,
        });
        await _sortActivities();
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error unliking activity: $e');
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _activityDatabaseService.deleteActivity(activityId);
      _activities.removeWhere((activity) => activity.id == activityId);
      notifyListeners();
      showSuccessSnackbar('Activity deleted');
    } catch (e) {
      _logger.severe('Error deleting activity: $e');
    }
  }

  Future<void> toggleReaction(String activityId, ReactionType type) async {
    try {
      final user = await _localStorageService.getCurrentUser();
      if (user == null) return;

      ActivityEvent? activity = await getActivity(activityId);

      if (activity == null) {
        _logger.warning('Activity $activityId not found');
        return;
      }

      final reactions = activity.reactions;
      debugPrint('checking reactions length: ${reactions.length.toString()}');
      debugPrint('reactions: $reactions');

      // Convert ReactionType to string for Firestore
      final currentReactions = (reactions[type] ?? []) as List<Reaction>;
      debugPrint('checking ID of user who reacted to activity: ${user.uid}');
      debugPrint(currentReactions.length.toString());

      // Check if user has already reacted
      final userReactionIndex = currentReactions.indexWhere(
        (r) => r.userId == user.uid,
      );

      if (userReactionIndex >= 0) {
        // Remove reaction
        currentReactions.removeAt(userReactionIndex);
      } else {
        // Add reaction
        currentReactions.add(Reaction(
          userId: user.uid,
          username: user.username,
          type: type,
          timestamp: DateTime.now(),
        ));
      }

      // Convert currentReactions to firebase friendly maps
      final convertedCurrentReactions =
          currentReactions.map((r) => r.toMap()).toList();

      // Update Firestore
      final reactionKey = type.toString().split('.').last;
      await _activityDatabaseService.updateActivity(activityId, {
        'reactions.$reactionKey': convertedCurrentReactions,
      });

      // Update local state
      final activityIndex = _activities.indexWhere((a) => a.id == activityId);
      if (activityIndex >= 0) {
        final activity = _activities[activityIndex];
        final updatedReactions =
            Map<ReactionType, List<Reaction>>.from(activity.reactions);

        if (currentReactions.isEmpty) {
          updatedReactions.remove(type);
        } else {
          updatedReactions[type] = currentReactions
              .map((r) => Reaction(
                    userId: r.userId,
                    username: r.username,
                    type: type,
                    timestamp: DateTime.parse(r.timestamp.toString()),
                  ))
              .toList();
        }

        _activities[activityIndex] = activity.copyWith(
          reactions: updatedReactions,
          userReaction: userReactionIndex >= 0 ? null : type,
        );

        await _sortActivities();
        notifyListeners();
        showSuccessSnackbar('Reaction updated');
      }
    } catch (e, stack) {
      _logger.severe('Error toggling reaction: $e');
      _logger.severe('Stack trace: $stack');
      showErrorSnackbar('There was a problem updating your reaction');
    }
  }

  Future<void> addComment(String activityId, Comment comment) async {
    try {
      await _activityDatabaseService.addComment(activityId, comment.toMap());
      _logger.info('Comment added to activity: $activityId');
    } catch (e) {
      _logger
          .severe('Error adding comment to activity: $activityId, Error: $e');
      throw e;
    }
  }

  Future<double> _calculateActivityScore(ActivityEvent activity) async {
    final baseWeight = _activityWeights[activity.type] ?? _baseScore;

    // Calculate engagement score
    final engagementScore = activity.likeCount * _likeWeight +
        activity.comments.length * _commentWeight;

    // Time decay (newer posts score higher)
    final ageInHours = DateTime.now().difference(activity.timestamp).inHours;
    final timeDecay = 1.0 / (1.0 + _timeDecayFactor * ageInHours);

    // Friend multiplier
    final user = await _localStorageService.getCurrentUser();
    final isFriend = user?.friends.contains(activity.userId) ?? false;
    final friendMultiplier = isFriend ? _friendMultiplier : 1.0;

    return baseWeight * (1 + engagementScore) * timeDecay * friendMultiplier;
  }

  Future<void> _sortActivities() async {
    // Create list of scores first to avoid calculating scores multiple times
    final scores = await Future.wait(
        _activities.map((activity) => _calculateActivityScore(activity)));

    // Create list of activity-score pairs for sorting
    final activityScores = List.generate(
      _activities.length,
      (i) => MapEntry(_activities[i], scores[i]),
    );

    // Sort the pairs by score
    activityScores.sort((a, b) => b.value.compareTo(a.value));

    // Update activities list with sorted order
    _activities = activityScores.map((e) => e.key).toList();
  }

  void enableActivityService() {
    _isEnabled = true;
    // Logic to enable activity service
    // For example, start processing activities
  }

  void disableActivityService() {
    _isEnabled = false;
    // Logic to disable activity service
    // For example, stop processing activities
  }
}
