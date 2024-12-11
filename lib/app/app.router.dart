// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i17;
import 'package:flutter/material.dart';
import 'package:habitur/models/shared_habit.dart' as _i18;
import 'package:habitur/ui/views/admin/admin_view.dart' as _i12;
import 'package:habitur/ui/views/community_leaderboard/community_leaderboard_view.dart'
    as _i11;
import 'package:habitur/ui/views/edit_habit/edit_habit_view.dart' as _i9;
import 'package:habitur/ui/views/habit_overview/habit_overview_view.dart'
    as _i10;
import 'package:habitur/ui/views/habits/habits_view.dart' as _i7;
import 'package:habitur/ui/views/home/home_view.dart' as _i6;
import 'package:habitur/ui/views/invite_participants/invite_participants_view.dart'
    as _i16;
import 'package:habitur/ui/views/login/login_view.dart' as _i4;
import 'package:habitur/ui/views/register/register_view.dart' as _i5;
import 'package:habitur/ui/views/settings/settings_view.dart' as _i13;
import 'package:habitur/ui/views/shared_habit_dashboard/shared_habit_dashboard_view.dart'
    as _i15;
import 'package:habitur/ui/views/shared_habits/shared_habits_view.dart' as _i14;
import 'package:habitur/ui/views/startup/startup_view.dart' as _i2;
import 'package:habitur/ui/views/statistics/statistics_view.dart' as _i8;
import 'package:habitur/ui/views/welcome/welcome_view.dart' as _i3;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i19;

class Routes {
  static const startupView = '/';

  static const welcomeView = '/welcome-view';

  static const loginView = '/login-view';

  static const registerView = '/register-view';

  static const homeView = '/home-view';

  static const habitsView = '/habits-view';

  static const statisticsView = '/statistics-view';

  static const editHabitView = '/edit-habit-view';

  static const habitOverviewView = '/habit-overview-view';

  static const communityLeaderboardView = '/community-leaderboard-view';

  static const adminView = '/admin-view';

  static const settingsView = '/settings-view';

  static const sharedHabitsView = '/shared-habits-view';

  static const sharedHabitDashboardView = '/shared-habit-dashboard-view';

  static const inviteParticipantsView = '/invite-participants-view';

  static const all = <String>{
    startupView,
    welcomeView,
    loginView,
    registerView,
    homeView,
    habitsView,
    statisticsView,
    editHabitView,
    habitOverviewView,
    communityLeaderboardView,
    adminView,
    settingsView,
    sharedHabitsView,
    sharedHabitDashboardView,
    inviteParticipantsView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.startupView,
      page: _i2.StartupView,
    ),
    _i1.RouteDef(
      Routes.welcomeView,
      page: _i3.WelcomeView,
    ),
    _i1.RouteDef(
      Routes.loginView,
      page: _i4.LoginView,
    ),
    _i1.RouteDef(
      Routes.registerView,
      page: _i5.RegisterView,
    ),
    _i1.RouteDef(
      Routes.homeView,
      page: _i6.HomeView,
    ),
    _i1.RouteDef(
      Routes.habitsView,
      page: _i7.HabitsView,
    ),
    _i1.RouteDef(
      Routes.statisticsView,
      page: _i8.StatisticsView,
    ),
    _i1.RouteDef(
      Routes.editHabitView,
      page: _i9.EditHabitView,
    ),
    _i1.RouteDef(
      Routes.habitOverviewView,
      page: _i10.HabitOverviewView,
    ),
    _i1.RouteDef(
      Routes.communityLeaderboardView,
      page: _i11.CommunityLeaderboardView,
    ),
    _i1.RouteDef(
      Routes.adminView,
      page: _i12.AdminView,
    ),
    _i1.RouteDef(
      Routes.settingsView,
      page: _i13.SettingsView,
    ),
    _i1.RouteDef(
      Routes.sharedHabitsView,
      page: _i14.SharedHabitsView,
    ),
    _i1.RouteDef(
      Routes.sharedHabitDashboardView,
      page: _i15.SharedHabitDashboardView,
    ),
    _i1.RouteDef(
      Routes.inviteParticipantsView,
      page: _i16.InviteParticipantsView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i2.StartupView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i3.WelcomeView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i3.WelcomeView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i4.LoginView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i4.LoginView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i5.RegisterView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i5.RegisterView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i6.HomeView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i6.HomeView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i7.HabitsView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i7.HabitsView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i8.StatisticsView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i8.StatisticsView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i9.EditHabitView: (data) {
      final args = data.getArgs<EditHabitViewArguments>(
        orElse: () => const EditHabitViewArguments(),
      );
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _i9.EditHabitView(key: args.key, habitId: args.habitId),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i10.HabitOverviewView: (data) {
      final args = data.getArgs<HabitOverviewViewArguments>(nullOk: false);
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _i10.HabitOverviewView(habitId: args.habitId, key: args.key),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i11.CommunityLeaderboardView: (data) {
      final args = data.getArgs<CommunityLeaderboardViewArguments>(
        orElse: () => const CommunityLeaderboardViewArguments(),
      );
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _i11.CommunityLeaderboardView(
                key: args.key, challengeId: args.challengeId),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i12.AdminView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i12.AdminView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i13.SettingsView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i13.SettingsView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i14.SharedHabitsView: (data) {
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _i14.SharedHabitsView(),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i15.SharedHabitDashboardView: (data) {
      final args =
          data.getArgs<SharedHabitDashboardViewArguments>(nullOk: false);
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _i15.SharedHabitDashboardView(
                key: args.key, sharedHabit: args.sharedHabit),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
    _i16.InviteParticipantsView: (data) {
      final args = data.getArgs<InviteParticipantsViewArguments>(nullOk: false);
      return _i17.PageRouteBuilder<dynamic>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _i16.InviteParticipantsView(
                key: args.key, sharedHabit: args.sharedHabit),
        settings: data,
        transitionsBuilder: data.transition ?? _i1.TransitionsBuilders.fadeIn,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class EditHabitViewArguments {
  const EditHabitViewArguments({
    this.key,
    this.habitId,
  });

  final _i17.Key? key;

  final String? habitId;

  @override
  String toString() {
    return '{"key": "$key", "habitId": "$habitId"}';
  }

  @override
  bool operator ==(covariant EditHabitViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.habitId == habitId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ habitId.hashCode;
  }
}

class HabitOverviewViewArguments {
  const HabitOverviewViewArguments({
    required this.habitId,
    this.key,
  });

  final String habitId;

  final _i17.Key? key;

  @override
  String toString() {
    return '{"habitId": "$habitId", "key": "$key"}';
  }

  @override
  bool operator ==(covariant HabitOverviewViewArguments other) {
    if (identical(this, other)) return true;
    return other.habitId == habitId && other.key == key;
  }

  @override
  int get hashCode {
    return habitId.hashCode ^ key.hashCode;
  }
}

class CommunityLeaderboardViewArguments {
  const CommunityLeaderboardViewArguments({
    this.key,
    this.challengeId,
  });

  final _i17.Key? key;

  final String? challengeId;

  @override
  String toString() {
    return '{"key": "$key", "challengeId": "$challengeId"}';
  }

  @override
  bool operator ==(covariant CommunityLeaderboardViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ challengeId.hashCode;
  }
}

class SharedHabitDashboardViewArguments {
  const SharedHabitDashboardViewArguments({
    this.key,
    required this.sharedHabit,
  });

  final _i17.Key? key;

  final _i18.SharedHabit sharedHabit;

  @override
  String toString() {
    return '{"key": "$key", "sharedHabit": "$sharedHabit"}';
  }

  @override
  bool operator ==(covariant SharedHabitDashboardViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.sharedHabit == sharedHabit;
  }

  @override
  int get hashCode {
    return key.hashCode ^ sharedHabit.hashCode;
  }
}

class InviteParticipantsViewArguments {
  const InviteParticipantsViewArguments({
    this.key,
    required this.sharedHabit,
  });

  final _i17.Key? key;

  final _i18.SharedHabit sharedHabit;

  @override
  String toString() {
    return '{"key": "$key", "sharedHabit": "$sharedHabit"}';
  }

  @override
  bool operator ==(covariant InviteParticipantsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.sharedHabit == sharedHabit;
  }

  @override
  int get hashCode {
    return key.hashCode ^ sharedHabit.hashCode;
  }
}

extension NavigatorStateExtension on _i19.NavigationService {
  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToWelcomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.welcomeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHabitsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.habitsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStatisticsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.statisticsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToEditHabitView({
    _i17.Key? key,
    String? habitId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.editHabitView,
        arguments: EditHabitViewArguments(key: key, habitId: habitId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHabitOverviewView({
    required String habitId,
    _i17.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.habitOverviewView,
        arguments: HabitOverviewViewArguments(habitId: habitId, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCommunityLeaderboardView({
    _i17.Key? key,
    String? challengeId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.communityLeaderboardView,
        arguments: CommunityLeaderboardViewArguments(
            key: key, challengeId: challengeId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.adminView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.settingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSharedHabitsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.sharedHabitsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSharedHabitDashboardView({
    _i17.Key? key,
    required _i18.SharedHabit sharedHabit,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.sharedHabitDashboardView,
        arguments: SharedHabitDashboardViewArguments(
            key: key, sharedHabit: sharedHabit),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToInviteParticipantsView({
    _i17.Key? key,
    required _i18.SharedHabit sharedHabit,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.inviteParticipantsView,
        arguments:
            InviteParticipantsViewArguments(key: key, sharedHabit: sharedHabit),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithWelcomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.welcomeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHabitsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.habitsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStatisticsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.statisticsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithEditHabitView({
    _i17.Key? key,
    String? habitId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.editHabitView,
        arguments: EditHabitViewArguments(key: key, habitId: habitId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHabitOverviewView({
    required String habitId,
    _i17.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.habitOverviewView,
        arguments: HabitOverviewViewArguments(habitId: habitId, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCommunityLeaderboardView({
    _i17.Key? key,
    String? challengeId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.communityLeaderboardView,
        arguments: CommunityLeaderboardViewArguments(
            key: key, challengeId: challengeId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.adminView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.settingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSharedHabitsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.sharedHabitsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSharedHabitDashboardView({
    _i17.Key? key,
    required _i18.SharedHabit sharedHabit,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.sharedHabitDashboardView,
        arguments: SharedHabitDashboardViewArguments(
            key: key, sharedHabit: sharedHabit),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithInviteParticipantsView({
    _i17.Key? key,
    required _i18.SharedHabit sharedHabit,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.inviteParticipantsView,
        arguments:
            InviteParticipantsViewArguments(key: key, sharedHabit: sharedHabit),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
