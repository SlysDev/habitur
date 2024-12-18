import 'package:confetti/confetti.dart';
import 'package:stacked/stacked.dart';

class StreakMilestoneDialogModel extends BaseViewModel {
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
}