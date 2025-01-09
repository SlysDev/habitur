// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../services/activity_database_service.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../services/community_service.dart';
import '../services/data_service.dart';
import '../services/database_service.dart';
import '../services/friends_service.dart';
import '../services/habit_service.dart';
import '../services/insight_generator_service.dart';
import '../services/local_storage_service.dart';
import '../services/network_service.dart';
import '../services/notification_scheduling_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/shared_habits_service.dart';
import '../services/stats/aggregate_stats_calculator_service.dart';
import '../services/stats/habit_stats_service.dart';
import '../services/stats/stats_calculation_service.dart';
import '../services/stats/stats_orchestration_service.dart';
import '../services/stats/user_stats_service.dart';
import '../services/status_service.dart';
import '../services/sync_service.dart';
import '../services/user_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => LocalStorageService());
  locator.registerLazySingleton(() => HabitService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => DataService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => SettingsService());
  locator.registerLazySingleton(() => CommunityService());
  locator.registerLazySingleton(() => NetworkService());
  locator.registerLazySingleton(() => ActivityService());
  locator.registerLazySingleton(() => ActivityDatabaseService());
  locator.registerLazySingleton(() => FriendsService());
  locator.registerLazySingleton(() => SharedHabitsService());
  locator.registerLazySingleton(() => InsightGeneratorService());
  locator.registerLazySingleton(() => SyncService());
  locator.registerLazySingleton(() => StatusService());
  locator.registerLazySingleton(() => StatsCalculationService());
  locator.registerLazySingleton(() => HabitStatsService());
  locator.registerLazySingleton(() => UserStatsService());
  locator.registerLazySingleton(() => AggregateStatsCalculatorService());
  locator.registerLazySingleton(() => StatsOrchestrationService());
  locator.registerLazySingleton(() => NotificationSchedulingService());
}
