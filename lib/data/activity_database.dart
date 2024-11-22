import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:habitur/models/activity_event.dart';

class ActivityDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'activities';
  final Logger _logger = Logger('ActivityDatabase');
  static const int _pageSize = 10;

  // Getter for the Firestore collection reference
  CollectionReference get collection {
    return _firestore.collection(_collection);
  }

  // Create activity in Firestore
  Future<DocumentReference> createActivity(ActivityEvent activity) async {
    try {
      _logger.info('🔵 Starting createActivity...');
      _logger.info('📝 Activity data: ${activity.toMap()}');
      
      final docRef = await _firestore.collection(_collection).add(activity.toMap());
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
      rethrow;
    }
  }

  // Get real-time stream of activities
  Stream<QuerySnapshot> getActivitiesStream(
      String userId, List<String> friends) {
    try {
      // If user has no friends, return empty stream
      if (friends.isEmpty) {
        _logger.info('👥 No friends found, returning empty stream');
        return Stream.empty();
      }

      _logger.info('🔄 Setting up activities stream for user: $userId');
      _logger.info('👥 Friends list: $friends');

      return collection
          .where('userId', whereIn: friends)
          .orderBy('timestamp', descending: true)
          .limit(_pageSize)
          .snapshots()
          .handleError((error) {
        _logger.severe('❌ Error in activities stream: $error');
        if (error.toString().contains('requires an index')) {
          _logger.info('ℹ️ Please create the required Firestore index for the activities collection.');
        }
        throw error;
      });
    } catch (e) {
      _logger.severe('❌ Error setting up activities stream: $e');
      rethrow;
    }
  }

  // Load initial page of activities
  Future<QuerySnapshot> loadInitialActivities(
      String userId, List<String> friends) async {
    try {
      // If user has no friends, return empty query snapshot
      if (friends.isEmpty) {
        return await FirebaseFirestore.instance
            .collection('activities')
            .limit(0)
            .get();
      }

      return await collection
          .where('visibleTo', arrayContains: userId)
          .where('userId', whereIn: friends)
          .orderBy('timestamp', descending: true)
          .limit(_pageSize)
          .get();
    } catch (e) {
      _logger.severe('Error loading initial activities: $e');
      rethrow;
    }
  }

  // Load more activities
  Future<QuerySnapshot> loadMoreActivities(
      String userId, List<String> friends, DocumentSnapshot lastDoc) async {
    try {
      // If user has no friends, return empty query snapshot
      if (friends.isEmpty) {
        return await FirebaseFirestore.instance
            .collection('activities')
            .limit(0)
            .get();
      }

      return await collection
          .where('visibleTo', arrayContains: userId)
          .where('userId', whereIn: friends)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDoc)
          .limit(_pageSize)
          .get();
    } catch (e) {
      _logger.severe('Error loading more activities: $e');
      rethrow;
    }
  }

  // Like an activity
  Future<void> likeActivity(String activityId, String userId) async {
    try {
      await collection.doc(activityId).update({
        'likes': FieldValue.arrayUnion([userId]),
        'likeCount': FieldValue.increment(1),
      });
    } catch (e) {
      _logger.severe('Error liking activity: $e');
      rethrow;
    }
  }

  // Unlike an activity
  Future<void> unlikeActivity(String activityId, String userId) async {
    try {
      await collection.doc(activityId).update({
        'likes': FieldValue.arrayRemove([userId]),
        'likeCount': FieldValue.increment(-1),
      });
    } catch (e) {
      _logger.severe('Error unliking activity: $e');
      rethrow;
    }
  }

  Future<void> updateActivity(
      String activityId, Map<String, dynamic> data) async {
    try {
      await collection.doc(activityId).update(data);
    } catch (e) {
      _logger.severe('Error updating activity: $e');
      rethrow;
    }
  }

  // Delete an activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await collection.doc(activityId).delete();
    } catch (e) {
      _logger.severe('Error deleting activity: $e');
      rethrow;
    }
  }

  // Add comment to activity
  Future<void> addComment(
      String activityId, Map<String, dynamic> comment) async {
    try {
      await collection.doc(activityId).update({
        'comments': FieldValue.arrayUnion([comment]),
      });
    } catch (e) {
      _logger.severe('Error adding comment: $e');
      rethrow;
    }
  }

  // Remove comment from activity
  Future<void> removeComment(
      String activityId, Map<String, dynamic> comment) async {
    try {
      await collection.doc(activityId).update({
        'comments': FieldValue.arrayRemove([comment]),
      });
    } catch (e) {
      _logger.severe('Error removing comment: $e');
      rethrow;
    }
  }
}
