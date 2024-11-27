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
      case 'stats':
        return 1;
      case 'social':
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
        return 'stats';
      case 2:
        return 'social';
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
        await _navigationService.navigateToHomeView();
        break;
      case 'stats':
        await _navigationService.navigateToStatisticsView();
        break;
      case 'social':
        await _navigationService.navigateToCommunityLeaderboardView();
        break;
      case 'settings':
        await _navigationService.navigateToSettingsView();
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
}
