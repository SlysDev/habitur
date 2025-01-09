import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/ui/widgets/emphasis_card/emphasis_card.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/rounded_progress_bar.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'community_challenge_card_viewmodel.dart';

class CommunityChallengeCard
    extends StackedView<CommunityChallengeCardViewModel> {
  final CommunityChallenge challenge;
  final Color color;
  final bool isAdmin;

  const CommunityChallengeCard({
    super.key,
    required this.challenge,
    this.color = kDarkGray,
    this.isAdmin = false,
  });

  @override
  Widget builder(
    BuildContext context,
    CommunityChallengeCardViewModel viewModel,
    Widget? child,
  ) {
    return isAdmin
        ? buildAdminCard(context, viewModel)
        : buildNormalCard(context, viewModel);
  }

  @override
  CommunityChallengeCardViewModel viewModelBuilder(BuildContext context) =>
      CommunityChallengeCardViewModel(challenge: challenge);

  @override
  void onViewModelReady(CommunityChallengeCardViewModel viewModel) {}

  Widget buildNormalCard(
    BuildContext context,
    CommunityChallengeCardViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: viewModel.isConnected
          ? viewModel.navigateToChallengeOverview
          : viewModel.navigateToChallengeOverview,
      child: ModernCard(
        opacity: 0.4,
        color: challenge.currentFullCompletions ==
                challenge.requiredFullCompletions
            ? kLightGreenAccent
            : viewModel.isConnected
                ? (challenge.isCompleted ? color.withOpacity(0.5) : color)
                : kDarkGray.withOpacity(0.1),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.groups,
                  size: 32,
                  color: viewModel.isConnected ? kOrangeAccent : kDarkGray),
            ),
            viewModel.isConnected
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularPercentIndicator(
                          animation: true,
                          animationDuration: 500,
                          animateFromLastPercent: true,
                          curve: Curves.ease,
                          radius: 50,
                          percent: viewModel.totalProgress,
                          progressColor: challenge.currentFullCompletions ==
                                  challenge.requiredFullCompletions
                              ? Colors.white
                              : kPrimaryColor,
                          backgroundColor: kBackgroundColor.withOpacity(0.3),
                          circularStrokeCap: CircularStrokeCap.round,
                          lineWidth: 10,
                          center: Text(
                            "${(viewModel.totalProgress * 100).toStringAsFixed(0)}%",
                            style: kHeadingTextStyle.copyWith(
                                color: Colors.white, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            alignment: AlignmentDirectional.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  challenge.title,
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return RoundedProgressBar(
                                      progress: viewModel.userProgress,
                                      width: constraints.maxWidth,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.no_accounts_rounded,
                              size: 32, color: kGray),
                          Text("Login to access",
                              style: kMainDescription.copyWith(color: kGray)),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildAdminCard(
    BuildContext context,
    CommunityChallengeCardViewModel viewModel,
  ) {
    Color color = kFadedBlue;
    return Slidable(
      child: Container(
        alignment: AlignmentDirectional.center,
        width: 475,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: !challenge.isCompleted ? color : color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: viewModel.isConnected
            ? Row(
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
                          percent: viewModel.totalProgress,
                          progressColor: kPrimaryColor,
                          backgroundColor: Colors.transparent,
                          circularStrokeCap: CircularStrokeCap.round,
                          lineWidth: 10,
                          center: Text(
                            "${(viewModel.totalProgress * 100).toStringAsFixed(0)}%",
                            style:
                                kHeadingTextStyle.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // total completions display
                      Row(
                        children: [
                          Text(
                            challenge.currentFullCompletions.toString(),
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
                    ],
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Container(
                    width: 175,
                    alignment: AlignmentDirectional.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          challenge.title,
                          style:
                              kHeadingTextStyle.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          challenge.description,
                          style: kMainDescription.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.center,
                child: SizedBox(
                    child: Icon(Icons.wifi_off, size: 32, color: kGray)),
              ),
      ),
    );
  }
}
