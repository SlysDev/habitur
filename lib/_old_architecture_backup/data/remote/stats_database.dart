import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
import 'package:habitur/models/stat_point.dart';

class StatsDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  final DataConverter dataConverter = DataConverter();

  Future<List<StatPoint>> getStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return dataConverter
            .dbListToStatPoints(userDoc.get('stats')['statPoints']);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return [];
    }
  }

  Future<void> updateStats(String userId, Map<String, dynamic> stats) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        List<Map<String, dynamic>> currentStats = [];
        if (userDoc.data()!.containsKey('stats') &&
            userDoc.get('stats')['statPoints'] != null) {
          currentStats = List<Map<String, dynamic>>.from(
              userDoc.get('stats')['statPoints']);
        }

        // Find today's stat point or create new one
        final now = DateTime.now();
        int todayIndex = currentStats.indexWhere((stat) {
          final date = (stat['date'] as Timestamp).toDate();
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        });

        if (todayIndex != -1) {
          // Update existing stat point
          currentStats[todayIndex].addAll(stats);
        } else {
          // Create new stat point
          stats['date'] = Timestamp.now();
          currentStats.add(stats);
        }

        // Update Firestore
        await userRef.update({
          'stats.statPoints': currentStats,
          'lastUpdated': Timestamp.now(),
        });

        // await lastUpdatedManager.syncLastUpdated(context, userId);
      }
    } catch (e) {
      debugPrint('Error updating stats: $e');
      rethrow;
    }
  }

  Future<void> addNewStat(String userId, StatPoint stat) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        List<Map<String, dynamic>> currentStats = [];
        if (userDoc.data()!.containsKey('stats') &&
            userDoc.get('stats')['statPoints'] != null) {
          currentStats = List<Map<String, dynamic>>.from(
              userDoc.get('stats')['statPoints']);
        }

        // Convert StatPoint to Map
        final statMap = {
          'date': Timestamp.fromDate(stat.date),
          'confidenceLevel': stat.confidenceLevel,
          'completions': stat.completions,
          'streak': stat.streak,
          'consistencyFactor': stat.consistencyFactor,
          'difficultyRating': stat.difficultyRating,
          'slopeCompletions': stat.slopeCompletions,
          'slopeConsistency': stat.slopeConsistency,
          'slopeConfidenceLevel': stat.slopeConfidenceLevel,
          'slopeDifficultyRating': stat.slopeDifficultyRating,
        };

        currentStats.add(statMap);

        // Update Firestore
        await userRef.update({
          'stats.statPoints': currentStats,
          'lastUpdated': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('Error adding new stat: $e');
      rethrow;
    }
  }

  Future<void> updateAllStats(String userId, List<StatPoint> stats) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Convert StatPoints to Maps
      final statMaps = stats
          .map((stat) => {
                'date': Timestamp.fromDate(stat.date),
                'confidenceLevel': stat.confidenceLevel,
                'completions': stat.completions,
                'streak': stat.streak,
                'consistencyFactor': stat.consistencyFactor,
                'difficultyRating': stat.difficultyRating,
                'slopeCompletions': stat.slopeCompletions,
                'slopeConsistency': stat.slopeConsistency,
                'slopeConfidenceLevel': stat.slopeConfidenceLevel,
                'slopeDifficultyRating': stat.slopeDifficultyRating,
              })
          .toList();

      // Update Firestore
      await userRef.update({
        'stats.statPoints': statMaps,
        'lastUpdated': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error updating all stats: $e');
      rethrow;
    }
  }
}
