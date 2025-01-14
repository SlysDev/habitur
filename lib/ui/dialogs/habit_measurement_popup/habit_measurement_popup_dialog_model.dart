import 'package:habitur/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitMeasurementPopupDialogModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  double currentValue = 0;

  void updateValue(double newValue) {
    currentValue = newValue;
    rebuildUi();
  }

  void submitDialog() {
    _dialogService.completeDialog(
      DialogResponse(confirmed: true, data: currentValue.toInt()),
    );
  }
}
