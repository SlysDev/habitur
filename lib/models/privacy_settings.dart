import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'privacy_settings.g.dart';

@HiveType(typeId: 5)
class PrivacySettings {
  @HiveField(0)
  final bool shareActivities;
  
  @HiveField(1)
  final bool shareHabitCompletions;
  
  @HiveField(2)
  final bool shareStreakMilestones;
  
  @HiveField(3)
  final bool shareNewHabits;
  
  @HiveField(4)
  final bool shareProfilePicture;

  const PrivacySettings({
    this.shareActivities = true,
    this.shareHabitCompletions = true,
    this.shareStreakMilestones = true,
    this.shareNewHabits = true,
    this.shareProfilePicture = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'shareActivities': shareActivities,
      'shareHabitCompletions': shareHabitCompletions,
      'shareStreakMilestones': shareStreakMilestones,
      'shareNewHabits': shareNewHabits,
      'shareProfilePicture': shareProfilePicture,
    };
  }

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      shareActivities: map['shareActivities'] as bool? ?? true,
      shareHabitCompletions: map['shareHabitCompletions'] as bool? ?? true,
      shareStreakMilestones: map['shareStreakMilestones'] as bool? ?? true,
      shareNewHabits: map['shareNewHabits'] as bool? ?? true,
      shareProfilePicture: map['shareProfilePicture'] as bool? ?? true,
    );
  }

  PrivacySettings copyWith({
    bool? shareActivities,
    bool? shareHabitCompletions,
    bool? shareStreakMilestones,
    bool? shareNewHabits,
    bool? shareProfilePicture,
  }) {
    return PrivacySettings(
      shareActivities: shareActivities ?? this.shareActivities,
      shareHabitCompletions: shareHabitCompletions ?? this.shareHabitCompletions,
      shareStreakMilestones: shareStreakMilestones ?? this.shareStreakMilestones,
      shareNewHabits: shareNewHabits ?? this.shareNewHabits,
      shareProfilePicture: shareProfilePicture ?? this.shareProfilePicture,
    );
  }
}
