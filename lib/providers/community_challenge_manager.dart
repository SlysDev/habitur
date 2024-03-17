import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/habit_manager.dart';

class CommunityChallengeManager extends HabitManager {
  List<Habit> _communityChallenges = [];

  @override
  UnmodifiableListView<Habit> get habits {
    return UnmodifiableListView(_communityChallenges);
  } // ensures inherited methods work on communityChallenges list
}
