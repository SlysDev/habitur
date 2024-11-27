import 'package:flutter/material.dart';

class LoadingStateProvider extends ChangeNotifier {
  bool isLoading = false;
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
