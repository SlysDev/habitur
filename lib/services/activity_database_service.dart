import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:stacked/stacked.dart';
import '../models/activity_event.dart';
import '../app/app.locator.dart';

class ActivityDatabaseService with ListenableServiceMixin {
  final _firestore = FirebaseFirestore.instance;
  final _logger = Logger('ActivityDatabaseService');
  static const String _collection = 'activities';
  static const int _pageSize = 10;
  bool _isEnabled = true;

  CollectionReference get collection => _firestore.collection(_collection);

  Future<DocumentReference> createActivity(ActivityEvent activity) async {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Future.error('Service disabled');
    }
    try {
      _logger.info('🔵 Starting createActivity...');
      _logger.info('📝 Activity data: ${activity.toMap()}');

      final docRef = await collection.add(activity.toMap());
      _logger.info('✅ Successfully created activity with ID: ${docRef.id}');
      _logger.info('📍 Document path: ${docRef.path}');

      // Verify the document was created
      final doc = await docRef.get();
      if (doc.exists) {
        _logger.info('✅ Verified document exists in Firestore');
        _logger.info('📄 Document data: ${doc.data()}');
      } else {
        _logger.severe('❌ Document does not exist after creation!');
      }

      return docRef;
    } catch (e, stack) {
      _logger.severe('❌ Error creating activity: $e');
      _logger.severe('Stack trace: $stack');
      if (e.toString().contains('permission-denied')) {
        _logger.info('🔒 This appears to be a permissions error');
      }
      return Future.error(e);
    }
  }

  Stream<QuerySnapshot> getActivitiesStream(
      String userId, List<String> friends) {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Stream.empty();
    }
    try {
      if (friends.isEmpty) {
        _logger.info('👥 No friends found, returning empty stream');
        return Stream.empty();
      }

      _logger.info('🔄 Setting up activities stream for user: $userId');
      _logger.info('👥 Friends list: $friends');

      return collection
          .where('userId', whereIn: [userId, ...friends])
          .orderBy('timestamp', descending: true)
          .limit(_pageSize)
          .snapshots()
          .handleError((error) {
            _logger.severe('❌ Error in activities stream: $error');
            if (error.toString().contains('missing index')) {
              _logger.info(
                  'ℹ️ Please create the required Firestore index for the activities collection.');
            }
            return Stream.empty();
          });
    } catch (e) {
      _logger.severe('❌ Error setting up activities stream: $e');
      return Stream.empty();
    }
  }

  Future<QuerySnapshot> getInitialActivities(
      String userId, List<String> friends) async {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Future.error('Service disabled');
    }
    try {
      return await collection
          .where('userId', whereIn: [userId, ...friends])
          .orderBy('timestamp', descending: true)
          .limit(_pageSize)
          .get();
    } catch (e) {
      _logger.severe('Error loading initial activities: $e');
      return Future.error(e);
    }
  }

  Future<QuerySnapshot> getMoreActivities(String userId, List<String> friends,
      DocumentSnapshot lastDocument) async {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Future.error('Service disabled');
    }
    try {
      return await collection
          .where('userId', whereIn: [userId, ...friends])
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument)
          .limit(_pageSize)
          .get();
    } catch (e) {
      _logger.severe('Error loading more activities: $e');
      return Future.error(e);
    }
  }

  Future<void> updateActivity(
      String activityId, Map<String, dynamic> data) async {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Future.error('Service disabled');
    }
    try {
      DocumentSnapshot doc = await _getActivityDoc(activityId);
      await doc.reference.update(data);
    } catch (e) {
      _logger.severe('Error updating activity: $e');
      rethrow;
    }
  }

  Future<void> deleteActivity(String activityId) async {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Future.error('Service disabled');
    }
    try {
      DocumentSnapshot doc = await _getActivityDoc(activityId);
      await doc.reference.delete();
    } catch (e) {
      _logger.severe('Error deleting activity: $e');
      rethrow;
    }
  }

  Future<void> addComment(
      String activityId, Map<String, dynamic> comment) async {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Future.error('Service disabled');
    }
    try {
      DocumentSnapshot doc = await _getActivityDoc(activityId);
      doc.reference.update({
        'comments': FieldValue.arrayUnion([comment]),
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      _logger.severe('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> removeComment(
      String activityId, Map<String, dynamic> comment) async {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Future.error('Service disabled');
    }
    try {
      DocumentSnapshot doc = await _getActivityDoc(activityId);
      doc.reference.update({
        'comments': FieldValue.arrayRemove([comment]),
        'commentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      _logger.severe('Error removing comment: $e');
      rethrow;
    }
  }

  Future<ActivityEvent?> getActivity(String activityId, String userId) async {
    if (!_isEnabled) {
      _logger.info('Activity database service is disabled');
      return Future.error('Service disabled');
    }
    try {
      _logger.info('🔍 Getting activity: $activityId for user: $userId');

      final doc = await _getActivityDoc(activityId);
      if (!doc.exists) {
        _logger.info('❌ Activity not found');
        return null;
      }

      final activity =
          ActivityEvent.fromMap(doc.data() as Map<String, dynamic>);

      _logger.info('✅ Successfully retrieved activity');
      return activity;
    } catch (e) {
      _logger.severe('❌ Error getting activity: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot> _getActivityDoc(String activityId) async {
    try {
      return await collection
          .where('id', isEqualTo: activityId)
          .get()
          .then((value) => value.docs[0]);
    } catch (e, s) {
      _logger.severe('❌ Error getting activity document: $e');
      _logger.info('$s');
      rethrow;
    }
  }

  void enableActivityDatabaseService() {
    _isEnabled = true;
    _logger.info('Activity database service is enabled');
  }

  void disableActivityDatabaseService() {
    _isEnabled = false;
    _logger.info('Activity database service is disabled');
  }
}
