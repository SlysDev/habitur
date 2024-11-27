## Old Architecture Backup

This directory contains backups of the original app architecture that has been migrated to the new Stacked architecture.
These files are kept for reference purposes only and should not be imported or used in the app.

### Migration Status

#### Components -> Widgets
Migrated:
- `components/line_graph.dart` -> `/lib/ui/widgets/line_graph/line_graph.dart`
- `components/stat_change_indicator.dart` -> `/lib/ui/widgets/stat_change_indicator/stat_change_indicator.dart`
- `components/habit_heat_map.dart` -> `/lib/ui/widgets/habit_heat_map/habit_heat_map.dart`
- `components/multi_stat_line_graph.dart` -> `/lib/ui/widgets/multi_stat_line_graph/multi_stat_line_graph.dart`

Pending Migration:
- `components/activity_item.dart`
- `components/community_challenge_card/*`
- `components/community_habit_list/*`
- `components/habit_card.dart`
- `components/habit_card_list.dart`
- `components/profile_dialog.dart`
- `components/profile_drawer.dart`
- `components/social_feed.dart`
- And many other UI components...

#### Screens -> Views
Migrated:
- `screens/habit_overview_screen.dart` -> `/lib/ui/views/habit_overview/habit_overview_view.dart`

Pending Migration:
- `screens/add_community_challenge_screen.dart`
- `screens/add_habit_screen.dart`
- `screens/admin-screen.dart`
- `screens/challenges_screen.dart`
- `screens/community_leaderboard_screen.dart`
- `screens/delete_account_login_screen.dart`
- `screens/edit_community_challenge_screen.dart`
- `screens/edit_habit_screen.dart`
- `screens/habits_screen.dart`
- `screens/home_screen.dart`
- `screens/login_screen.dart`
- `screens/register_screen.dart`
- `screens/settings_screen.dart`
- `screens/splash_screen.dart`
- `screens/statistics_screen.dart`
- `screens/welcome_screen.dart`

#### Providers -> Services & ViewModels
Migrated:
- Provider-based state management -> Stacked ViewModels and ReactiveServices

Pending Migration:
- `providers/activity_provider.dart`
- `providers/add_habit_screen_provider.dart`
- `providers/community_challenge_manager.dart`
- `providers/database.dart`
- `providers/days_of_week_selector_provider.dart`
- `providers/habit_manager.dart`
- `providers/loading_state_provider.dart`
- `providers/local_storage.dart`
- `providers/login_registration_state.dart`
- `providers/network_state_provider.dart`

### Directory Structure
```
_old_architecture_backup/
├── components/         # Old UI components
├── screens/           # Old screen implementations
└── providers/         # Old provider implementations
```

### Notes
- This backup is maintained for reference during the migration process
- All new development should use the Stacked architecture
- After migration is complete and thoroughly tested, this backup can be archived
- The services directory is not included as it already uses Stacked architecture
