import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/navbar/navbar_model.dart';

class NavBar extends StackedView<NavBarModel> {
  final String currentPage;

  const NavBar({
    this.currentPage = 'home',
    Key? key,
  }) : super(key: key);

  @override
  Widget builder(BuildContext context, NavBarModel viewModel, Widget? child) {
    return Container(
      padding: const EdgeInsets.only(bottom: 30, top: 15),
      decoration: BoxDecoration(
        color: kFadedBlue.withOpacity(0.4),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            page: 'home',
            viewModel: viewModel,
          ),
          _buildNavItem(
            icon: Icons.check_circle_rounded,
            page: 'habits',
            viewModel: viewModel,
          ),
          _buildAddButton(viewModel),
          _buildNavItem(
            icon: Icons.bar_chart_rounded,
            page: 'statistics',
            viewModel: viewModel,
          ),
          _buildNavItem(
            icon: Icons.settings_rounded,
            page: 'settings',
            viewModel: viewModel,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String page,
    required NavBarModel viewModel,
  }) {
    return GestureDetector(
      onTap: () => viewModel.navigateToPage(page),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          color: viewModel.currentPage == page ? kPrimaryColor : kGray,
          size: 25,
        ),
      ),
    );
  }

  Widget _buildAddButton(NavBarModel viewModel) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: viewModel.showAddHabitSheet,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(15),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  NavBarModel viewModelBuilder(BuildContext context) => NavBarModel();

  @override
  void onViewModelReady(NavBarModel viewModel) =>
      viewModel.initialize(currentPage);
}
