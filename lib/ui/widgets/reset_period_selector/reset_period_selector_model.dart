import 'package:stacked/stacked.dart';

class ResetPeriodSelectorModel extends BaseViewModel {
  String _resetPeriod = 'Daily';
  get resetPeriod => _resetPeriod;

  void initialize(String resetPeriod) {
    _resetPeriod = resetPeriod;
    rebuildUi();
  }

  void setResetPeriod(String period) {
    _resetPeriod = period;
    rebuildUi();
  }
}
