import 'package:flutter/material.dart';

class LoadingData extends ChangeNotifier {
  bool isLoading = false;
  void toggleLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void disableLoading() {
    isLoading = false;
    notifyListeners();
  }
}
