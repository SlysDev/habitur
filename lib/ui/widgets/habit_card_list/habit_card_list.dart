import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/habit_card/habit_card.dart';
import 'package:habitur/ui/widgets/inactive_habit_card/inactive_habit_card.dart';
import 'package:stacked/stacked.dart';

import 'habit_card_list_model.dart';

class HabitCardList extends StackedView<HabitCardListModel> {
  const HabitCardList({super.key});

  @override
  Widget builder(
    BuildContext context,
    HabitCardListModel viewModel,
    Widget? child,
  ) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: RefreshIndicator(
          backgroundColor: kPrimaryColor,
          color: Colors.white,
          onRefresh: () async {
            await viewModel.onRefresh();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              return viewModel.habitIsDueToday(index)
                  ? Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        HabitCard(
                          index: index,
                        ),
                        // color: Provider.of<HabitManager>(context, listen: false).habits[index].color),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        InactiveHabitCard(
                          index: index,
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    );
            },
            itemCount: viewModel.habits.length,
          ),
        ),
      ),
    );
  }

  @override
  HabitCardListModel viewModelBuilder(
    BuildContext context,
  ) =>
      HabitCardListModel();
}
