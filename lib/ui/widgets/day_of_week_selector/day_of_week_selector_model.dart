import 'package:stacked/stacked.dart';

class DaysOfWeekSelectorModel extends BaseViewModel {
  List<String> _selectedDays = [];
  List<String> get selectedDays => _selectedDays;

  void initialize(List<String> days) {
    _selectedDays = days;
    rebuildUi();
  }

  void toggleDay(String day) {
    if (_selectedDays.contains(day)) {
      _selectedDays.remove(day);
    } else {
      _selectedDays.add(day);
    }
    rebuildUi();
  }
}
