import 'package:habitur/app/app.locator.dart';
import 'package:habitur/services/network_service.dart';
import 'package:stacked/stacked.dart';

class NetworkIndicatorModel extends BaseViewModel {
  final _networkService = locator<NetworkService>();

  bool get isConnected => _networkService.isConnected;
}
