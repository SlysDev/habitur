import 'package:flutter/foundation.dart';

class NetworkStateProvider extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  set isConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }
}
