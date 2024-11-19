import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:logging/logging.dart';

class ActivityDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'activities';
  final Logger _logger = Logger('ActivityDatabase');
  static const int _pageSize = 10;

  // Getter for the Firestore collection reference
  CollectionReference get collection => _firestore.collection(_collection);

  // Create activity in Firestore
  Future<DocumentReference> createActivity(ActivityEvent activity) async {
    try {
      return await collection.add(activity.toMap());
    } catch (e) {
      _logger.severe('Error creating activity: $e');
      rethrow;
    }
  }

  // Get real-time stream of activities
  Stream<QuerySnapshot> getActivitiesStream(String userId) {
    try {
      return collection
          .where('visibleTo', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .limit(_pageSize)
          .snapshots()
          .handleError((error) {
            _logger.severe('Error in activities stream: $error');
            if (error.toString().contains('requires an index')) {
              _logger.info('Please create the required Firestore index for the activities collection.');
            }
            throw error;
          });
    } catch (e) {
      _logger.severe('Error setting up activities stream: $e');
      rethrow;
    }
  }

  // Load initial page of activities
  Future<QuerySnapshot> loadInitialActivities(String userId) async {
    try {
      return await collection
          .where('visibleTo', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .limit(_pageSize)
          .get();
    } catch (e) {
      _logger.severe('Error loading initial activities: $e');
      rethrow;
    }
  }

  // Load more activities (pagination)
  Future<QuerySnapshot> loadMoreActivities(String userId, DocumentSnapshot lastDocument) async {
    try {
      return await collection
          .where('visibleTo', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument)
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

  Future<void> updateActivity(String activityId, Map<String, dynamic> data) async {
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
  Future<void> addComment(String activityId, Map<String, dynamic> comment) async {
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
  Future<void> removeComment(String activityId, Map<String, dynamic> comment) async {
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
