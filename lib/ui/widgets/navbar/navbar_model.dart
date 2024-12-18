import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';

import '../../../enums/bottom_sheet_type.dart';

class NavBarModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();

  String _currentPage = 'home';

  get currentPage => _currentPage;

  void initialize(String currentPage) {
    _currentPage = currentPage;
    notifyListeners();
  }

  int getCurrentIndex(String page) {
    switch (page.toLowerCase()) {
      case 'home':
        return 0;
      case 'habits':
        return 1;
      case 'stats':
        return 2;
      case 'settings':
        return 3;
      default:
        return 0;
    }
  }

  String getPageFromIndex(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'habits';
      case 2:
        return 'stats';
      case 3:
        return 'settings';
      default:
        return 'home';
    }
  }

  Future<void> navigateToPage(String page) async {
    if (page == _currentPage) return;

    switch (page.toLowerCase()) {
      case 'home':
        _navigationService.navigateToHomeView();
        // await _navigationService.navigateToHomeRevampView();
        break;
      case 'habits':
        _navigationService.navigateToHabitsView();
        break;
      case 'stats':
        _navigationService.navigateToStatisticsView();
        break;
      case 'settings':
        _navigationService.navigateToSettingsView();
        break;
    }
    _currentPage = page;
    notifyListeners();
  }

  void handleNavigation(int index) {
    navigateToPage(getPageFromIndex(index));
  }

  Future<void> showAddHabitSheet() async {
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.addHabit,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  Future<void> showCreateSharedHabitSheet() async {
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.createSharedHabit,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }
}
