import 'package:confetti/confetti.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LevelUpDialogModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  late ConfettiController confettiController;

  void initialize() {
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    confettiController.play();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void closeDialog() {
    _dialogService.completeDialog(DialogResponse(confirmed: true));
  }
}
