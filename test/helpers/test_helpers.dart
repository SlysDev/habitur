import 'package:habitur/app/app.locator.dart';
import 'package:habitur/services/activity_service.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import 'test_helpers.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FriendsService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<HabitService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<SharedHabitsService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<UserService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<ActivityService>(onMissingStub: OnMissingStub.returnDefault),
])
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterDialogService();
  getAndRegisterFriendsService();
  getAndRegisterHabitService();
  getAndRegisterSharedHabitsService();
  getAndRegisterUserService();
  getAndRegisterActivityService();
}

void unregisterServices() {
  locator.unregister<NavigationService>();
  locator.unregister<DialogService>();
  locator.unregister<FriendsService>();
  locator.unregister<HabitService>();
  locator.unregister<SharedHabitsService>();
  locator.unregister<UserService>();
  locator.unregister<ActivityService>();
}

NavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

DialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

FriendsService getAndRegisterFriendsService() {
  _removeRegistrationIfExists<FriendsService>();
  final service = MockFriendsService();
  locator.registerSingleton<FriendsService>(service);
  return service;
}

HabitService getAndRegisterHabitService() {
  _removeRegistrationIfExists<HabitService>();
  final service = MockHabitService();
  locator.registerSingleton<HabitService>(service);
  return service;
}

SharedHabitsService getAndRegisterSharedHabitsService() {
  _removeRegistrationIfExists<SharedHabitsService>();
  final service = MockSharedHabitsService();
  locator.registerSingleton<SharedHabitsService>(service);
  return service;
}

UserService getAndRegisterUserService() {
  _removeRegistrationIfExists<UserService>();
  final service = MockUserService();
  locator.registerSingleton<UserService>(service);
  return service;
}

ActivityService getAndRegisterActivityService() {
  _removeRegistrationIfExists<ActivityService>();
  final service = MockActivityService();
  locator.registerSingleton<ActivityService>(service);
  return service;
}

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
