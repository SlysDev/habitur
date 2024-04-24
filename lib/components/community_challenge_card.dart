import 'package:flutter/material.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CommunityChallengeCard extends StatelessWidget {
  String title;
  String description;
  void Function() onTap;
  void Function() onLongPress;
  Color color;
  double totalProgress;
  double userProgress;
  bool completed;
  int completionCount;
  int totalFullCompletions;
  void Function(BuildContext) onDismissed;
  void Function(BuildContext) onEdit;
  CommunityChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.totalProgress,
    required this.userProgress,
    required this.onTap,
    required this.completionCount,
    required this.totalFullCompletions,
    required this.onLongPress,
    this.color = kFadedBlue,
    required this.completed,
    required this.onDismissed,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        alignment: AlignmentDirectional.center,
        duration: const Duration(milliseconds: 500),
        height: 275,
        curve: Curves.ease,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: !completed ? color : color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    child: CircularPercentIndicator(
                      animation: true,
                      animationDuration: 500,
                      animateFromLastPercent: true,
                      curve: Curves.ease,
                      radius: 60,
                      percent: totalProgress,
                      progressColor: kPrimaryColor,
                      backgroundColor: Colors.transparent,
                      circularStrokeCap: CircularStrokeCap.round,
                      lineWidth: 10,
                      center: Text(
                        "${(totalProgress * 100).toStringAsFixed(0)}%",
                        style: kHeadingTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // total completions display
                  Row(
                    children: [
                      Text(
                        totalFullCompletions.toString(),
                        style: kMainDescription.copyWith(
                            color: Colors.white, fontSize: 22),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.people,
                        size: 24,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(),
                      SizedBox(
                        width: 10,
                      ),
                      CircleAvatar(),
                      SizedBox(
                        width: 10,
                      ),
                      CircleAvatar(),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 30,
              ),
              Container(
                width: 150,
                alignment: AlignmentDirectional.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: kHeadingTextStyle.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      description,
                      style: kMainDescription.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    RoundedProgressBar(progress: userProgress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
