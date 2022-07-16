import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class HabitCard extends StatelessWidget {
  String title;
  void Function() onTap;
  Color color;
  int index;
  double currentValue;
  double afterValue;
  bool completed;
  void Function(DismissDirection) onDismissed;
  HabitCard({
    required this.title,
    required this.currentValue,
    required this.afterValue,
    required this.onTap,
    required this.index,
    required this.color,
    required this.completed,
    required this.onDismissed,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Provider.of<UserData>(context)
                .userHabits[index]
                .currentCompletions !=
            Provider.of<UserData>(context)
                .userHabits[index]
                .requiredCompletions) {
          Provider.of<UserData>(context)
              .userHabits[index]
              .incrementCompletion();
          Provider.of<UserData>(context).updateUserData();
        }
      },
      child: Dismissible(
        onDismissed: onDismissed,
        key: Key(title),
        background: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: kBarnRed),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: !completed ? color : kSlateGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: kHeadingTextStyle.copyWith(color: Colors.white),
              ),
              const SizedBox(
                height: 15,
              ),
              AnimatedLinearProgressBar(
                currentValue: currentValue,
                afterValue: afterValue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedLinearProgressBar extends StatefulWidget {
  const AnimatedLinearProgressBar({
    Key? key,
    required this.currentValue,
    required this.afterValue,
  }) : super(key: key);

  final double currentValue;
  final double afterValue;

  @override
  State<AnimatedLinearProgressBar> createState() =>
      _AnimatedLinearProgressBarState();
}

class _AnimatedLinearProgressBarState extends State<AnimatedLinearProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation _animation;
  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    controller.addStatusListener((AnimationStatus status) {});
    _animation = Tween<double>(
      begin: widget.currentValue,
      end: widget.afterValue,
    ).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      percent: widget.currentValue,
      barRadius: const Radius.circular(30),
      lineHeight: 12.0,
      progressColor: Colors.white,
      backgroundColor: Colors.white24,
    );
  }
}

class RoundedWhiteCheckbox extends StatelessWidget {
  bool value;
  RoundedWhiteCheckbox({required this.value});
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: Checkbox(
        fillColor: MaterialStateProperty.all(Colors.white),
        value: value,
        onChanged: null,
        checkColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(width: 20, color: Colors.white),
        ),
      ),
    );
  }
}
