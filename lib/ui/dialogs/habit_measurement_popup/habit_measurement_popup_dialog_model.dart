import 'package:habitur/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitMeasurementPopupDialogModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  late double currentValue;
  bool _isInitialized = false;

  void initialize(double? initialValue) {
    if (!_isInitialized) {
      currentValue = initialValue ?? 0.0;
      _isInitialized = true;
    }
  }

  void updateValue(double newValue) {
    currentValue = newValue;
    notifyListeners();
  }

  void submitDialog() {
    _dialogService.completeDialog(
      DialogResponse(confirmed: true, data: currentValue),
    );
  }

  void cancelDialog() {
    _dialogService.completeDialog(DialogResponse(
      confirmed: false,
    ));
  }
}
