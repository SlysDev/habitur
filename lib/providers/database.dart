import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/remote/community_challenge_database.dart';
import 'package:habitur/data/remote/data_converter.dart';
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
  UserDatabase userDatabase = UserDatabase();
  HabitDatabase habitDatabase = HabitDatabase();
  CommunityChallengeDatabase communityChallengeDatabase =
      CommunityChallengeDatabase();
  StatsDatabase statsDatabase = StatsDatabase();
  SettingsDatabase settingsDatabase = SettingsDatabase();
  DataConverter dataConverter = DataConverter();
  LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  // Helper Functions
  Future<void> loadData(context) async {
    await userDatabase.loadUserData(context);
    await habitDatabase.loadHabits(context);
    await statsDatabase.loadStatistics(context);
    await communityChallengeDatabase.loadCommunityChallenges(context);
  }

  void uploadData(context) async {
    userDatabase.uploadUserData(context);
    habitDatabase.uploadHabits(context);
    statsDatabase.uploadStatistics(context);
    communityChallengeDatabase.uploadCommunityChallenges(context);
  }
}
