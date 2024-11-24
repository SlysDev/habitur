import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/remote/community_challenge_database.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/friends_database.dart';
import 'package:habitur/data/remote/habit_database.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
import 'package:habitur/data/remote/settings_database.dart';
import 'package:habitur/data/remote/stats_database.dart';
import 'package:habitur/data/remote/user_database.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:provider/provider.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class Database {
  static Database? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserDatabase userDatabase = UserDatabase();
  final StatsDatabase statsDatabase = StatsDatabase();
  final HabitDatabase habitDatabase = HabitDatabase();
  final CommunityChallengeDatabase communityChallengeDatabase = CommunityChallengeDatabase();
  final SettingsDatabase settingsDatabase = SettingsDatabase();
  final FriendsDatabase friendsDatabase = FriendsDatabase();
  final DataConverter dataConverter = DataConverter();
  final LastUpdatedManager lastUpdatedManager = LastUpdatedManager();

  Database._();

  factory Database() {
    _instance ??= Database._();
    return _instance!;
  }

  void _initializeFirestore() {
    // Enable Firestore persistence
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Helper Functions
  Future<void> loadData(context) async {
    final futures = await Future.wait([
      userDatabase.loadUserData(context),
      habitDatabase.loadHabits(context),
      statsDatabase.loadStatistics(context),
      settingsDatabase.loadData(context),
      communityChallengeDatabase.loadCommunityChallenges(context),
    ]);
  }

  Future<void> uploadData(context) async {
    // Start all uploads in parallel
    await Future.wait([
      userDatabase.uploadUserData(context),
      habitDatabase.uploadHabits(context),
      statsDatabase.uploadStatistics(context),
      communityChallengeDatabase.uploadCommunityChallenges(context),
    ]);
  }

  void dispose() {
    // Clean up any resources if needed
    _instance = null;
  }
}
