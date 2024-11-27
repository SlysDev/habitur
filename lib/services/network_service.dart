import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService with ReactiveServiceMixin {
  final _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  final ReactiveValue<bool> _isConnected = ReactiveValue<bool>(true);
  bool get isConnected => _isConnected.value;

  NetworkService() {
    listenToReactiveValues([_isConnected]);
    _initConnectivity();
    _setupConnectivityStream();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _isConnected.value = false;
    }
  }

  void _setupConnectivityStream() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected.value = result != ConnectivityResult.none;
    notifyListeners();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
