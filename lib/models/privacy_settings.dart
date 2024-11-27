import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'privacy_settings.g.dart';

@HiveType(typeId: 6)
enum SharingScope {
  @HiveField(0)
  none,
  @HiveField(1)
  friends,
  @HiveField(2)
  everyone,
}

@HiveType(typeId: 5)
class PrivacySettings {
  @HiveField(0)
  final SharingScope statsScope;

  @HiveField(1)
  final SharingScope habitsScope;

  @HiveField(2)
  final bool shareConfidenceLevel;

  @HiveField(3)
  final bool shareConsistencyFactor;

  @HiveField(4)
  final bool shareActivities;

  @HiveField(5)
  final bool shareHabitCompletions;

  @HiveField(6)
  final bool shareStreakMilestones;

  @HiveField(7)
  final bool shareNewHabits;

  @HiveField(8)
  final bool shareProfilePicture;

  const PrivacySettings({
    this.statsScope = SharingScope.friends,
    this.habitsScope = SharingScope.friends,
    this.shareConfidenceLevel = true,
    this.shareConsistencyFactor = true,
    this.shareActivities = true,
    this.shareHabitCompletions = true,
    this.shareStreakMilestones = true,
    this.shareNewHabits = true,
    this.shareProfilePicture = true,
  });

  // Helper method to check if stats sharing is enabled
  bool get isStatsSharingEnabled =>
      statsScope != SharingScope.none &&
      (shareConfidenceLevel || shareConsistencyFactor);

  // Helper method to check if habits should be shared with a specific user
  bool shouldShareStatsWith(bool isFriend) {
    switch (statsScope) {
      case SharingScope.none:
        return false;
      case SharingScope.friends:
        return isFriend;
      case SharingScope.everyone:
        return true;
    }
  }

  // Helper method to check if habits should be shared with a specific user
  bool shouldShareHabitsWith(bool isFriend) {
    switch (habitsScope) {
      case SharingScope.none:
        return false;
      case SharingScope.friends:
        return isFriend;
      case SharingScope.everyone:
        return true;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'statsScope': statsScope.toString(),
      'habitsScope': habitsScope.toString(),
      'shareConfidenceLevel': shareConfidenceLevel,
      'shareConsistencyFactor': shareConsistencyFactor,
      'shareActivities': shareActivities,
      'shareHabitCompletions': shareHabitCompletions,
      'shareStreakMilestones': shareStreakMilestones,
      'shareNewHabits': shareNewHabits,
      'shareProfilePicture': shareProfilePicture,
    };
  }

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      statsScope: _scopeFromString(map['statsScope']) ?? SharingScope.friends,
      habitsScope: _scopeFromString(map['habitsScope']) ?? SharingScope.friends,
      shareConfidenceLevel: map['shareConfidenceLevel'] as bool? ?? true,
      shareConsistencyFactor: map['shareConsistencyFactor'] as bool? ?? true,
      shareActivities: map['shareActivities'] as bool? ?? true,
      shareHabitCompletions: map['shareHabitCompletions'] as bool? ?? true,
      shareStreakMilestones: map['shareStreakMilestones'] as bool? ?? true,
      shareNewHabits: map['shareNewHabits'] as bool? ?? true,
      shareProfilePicture: map['shareProfilePicture'] as bool? ?? true,
    );
  }

  /// Safely converts a string to SharingScope enum
  static SharingScope? _scopeFromString(dynamic value) {
    if (value == null) return null;
    if (value is SharingScope) return value;

    switch (value.toString().toLowerCase()) {
      case 'none':
        return SharingScope.none;
      case 'friends':
        return SharingScope.friends;
      case 'everyone':
        return SharingScope.everyone;
      default:
        return null;
    }
  }

  PrivacySettings copyWith({
    SharingScope? statsScope,
    SharingScope? habitsScope,
    bool? shareConfidenceLevel,
    bool? shareConsistencyFactor,
    bool? shareActivities,
    bool? shareHabitCompletions,
    bool? shareStreakMilestones,
    bool? shareNewHabits,
    bool? shareProfilePicture,
  }) {
    return PrivacySettings(
      statsScope: statsScope ?? this.statsScope,
      habitsScope: habitsScope ?? this.habitsScope,
      shareConfidenceLevel: shareConfidenceLevel ?? this.shareConfidenceLevel,
      shareConsistencyFactor:
          shareConsistencyFactor ?? this.shareConsistencyFactor,
      shareActivities: shareActivities ?? this.shareActivities,
      shareHabitCompletions:
          shareHabitCompletions ?? this.shareHabitCompletions,
      shareStreakMilestones:
          shareStreakMilestones ?? this.shareStreakMilestones,
      shareNewHabits: shareNewHabits ?? this.shareNewHabits,
      shareProfilePicture: shareProfilePicture ?? this.shareProfilePicture,
    );
  }
}
