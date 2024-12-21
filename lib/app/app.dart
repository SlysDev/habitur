import 'package:habitur/services/notification_scheduling_service.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/stats/aggregate_stats_calculator_service.dart';
import 'package:habitur/services/stats/habit_stats_service.dart';
import 'package:habitur/services/stats/stats_orchestration_service.dart';
import 'package:habitur/services/stats/user_stats_service.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';
import 'package:habitur/services/status_service.dart';
import 'package:habitur/services/sync_service.dart';
import 'package:habitur/ui/views/edit_shared_habit/edit_shared_habit_view.dart';
import 'package:habitur/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// Services
import '../services/activity_database_service.dart';
import '../services/database_service.dart';
import '../services/insight_generator_service.dart';
import '../services/local_storage_service.dart';
import '../services/habit_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../services/community_service.dart';
import '../services/network_service.dart';
import '../services/activity_service.dart';
import '../services/friends_service.dart';

// Views
import '../ui/views/admin/admin_view.dart';
import '../ui/views/community_leaderboard/community_leaderboard_view.dart';
import '../ui/views/habits/habits_view.dart';
import '../ui/views/settings/settings_view.dart';
import '../ui/views/welcome/welcome_view.dart';
import '../ui/views/login/login_view.dart';
import '../ui/views/register/register_view.dart';
import '../ui/views/home/home_view.dart';
import '../ui/views/statistics/statistics_view.dart';
import '../ui/views/edit_habit/edit_habit_view.dart';
import '../ui/views/habit_overview/habit_overview_view.dart';
import '../ui/views/shared_habit_dashboard/shared_habit_dashboard_view.dart';

import 'package:habitur/ui/dialogs/streak_milestone/streak_milestone_dialog.dart';

import 'package:habitur/ui/dialogs/streak_milestone/streak_milestone_dialog.dart';

import 'package:habitur/ui/bottom_sheets/action_selection/action_selection_sheet.dart';

import 'package:habitur/ui/bottom_sheets/action_selection/action_selection_sheet.dart';

import 'package:habitur/ui/dialogs/select_friends/select_friends_dialog.dart';

import 'package:habitur/ui/dialogs/level_up/level_up_dialog.dart';

// @stacked-import
@StackedApp(
  routes: [
    CustomRoute(
      page: StartupView,
      initial: true,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: WelcomeView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: LoginView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: RegisterView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: HomeView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: HabitsView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: StatisticsView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: EditHabitView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: HabitOverviewView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: CommunityLeaderboardView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: AdminView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: SettingsView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: SharedHabitDashboardView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: EditSharedHabitView,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: DatabaseService),
    LazySingleton(classType: LocalStorageService),
    LazySingleton(classType: HabitService),
    LazySingleton(classType: UserService),
    LazySingleton(classType: NotificationService),
    LazySingleton(classType: DataService),
    LazySingleton(classType: AuthService),
    LazySingleton(classType: SettingsService),
    LazySingleton(classType: CommunityService),
    LazySingleton(classType: NetworkService),
    LazySingleton(classType: ActivityService),
    LazySingleton(classType: ActivityDatabaseService),
    LazySingleton(classType: FriendsService),
    LazySingleton(classType: SharedHabitsService),
    LazySingleton(classType: InsightGeneratorService),
    LazySingleton(classType: SyncService),
    LazySingleton(classType: StatusService),
    LazySingleton(classType: StatsCalculationService),
    LazySingleton(classType: HabitStatsService),
    LazySingleton(classType: UserStatsService),
    LazySingleton(classType: AggregateStatsCalculatorService),
    LazySingleton(classType: StatsOrchestrationService),
    LazySingleton(classType: NotificationSchedulingService),
    // @stacked-service
  ],
  dialogs: [
    StackedDialog(classType: StreakMilestoneDialog),
    StackedDialog(classType: SelectFriendsDialog),
    StackedDialog(classType: LevelUpDialog),
// @stacked-dialog
  ],
  bottomsheets: [
    StackedBottomsheet(classType: ActionSelectionSheet),
// @stacked-bottom-sheet
  ],
  logger: StackedLogger(),
)
class App {}
