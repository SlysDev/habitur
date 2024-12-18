import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/ui/widgets/line_graph/line_graph.dart';
import 'multi_stat_line_graph_model.dart';

class MultiStatLineGraph extends StackedView<MultiStatLineGraphModel> {
  final List<StatPoint> data;
  final double height;
  final double width;
  final bool showDots;
  final bool showStatTitle;
  final bool showChangeIndicator;
  final List<String> statOptions;

  const MultiStatLineGraph({
    required this.data,
    this.height = 200,
    this.width = 400,
    this.showDots = true,
    this.showStatTitle = false,
    this.showChangeIndicator = false,
    this.statOptions = const [
      'confidenceLevel',
      'difficultyRating',
      'consistencyFactor',
      'completions',
    ],
    super.key,
  });

  @override
  Widget builder(
      BuildContext context, MultiStatLineGraphModel viewModel, Widget? child) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kIsWeb
              ? _buildDropdown(viewModel)
              : Platform.isIOS
                  ? _buildCupertinoPicker(viewModel, context)
                  : _buildDropdown(viewModel),
          const SizedBox(height: 16),
          Flexible(
            fit: FlexFit.loose,
            child: LineGraph(
              title: viewModel.mappedStatName,
              data: data,
              width: width,
              height: height,
              statName: viewModel.displayedStat,
              showChangeIndicator: showChangeIndicator,
              showStatTitle: showStatTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(MultiStatLineGraphModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kFadedBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: viewModel.displayedStat,
        icon: const Icon(Icons.arrow_downward_rounded, color: Colors.white),
        elevation: 0,
        dropdownColor: kFadedBlue,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'DM Sans',
          fontSize: 16,
        ),
        underline: Container(),
        onChanged: (String? newValue) {
          if (newValue != null) viewModel.setDisplayedStat(newValue);
        },
        items: viewModel.statDisplayItems.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item.value,
            child: Text(item.displayName),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCupertinoPicker(
      MultiStatLineGraphModel viewModel, BuildContext context) {
    return Stack(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kFadedBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  viewModel.mappedStatName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                  ),
                ),
                const Icon(CupertinoIcons.chevron_down, color: Colors.white),
              ],
            ),
          ),
          onPressed: () => _showCupertinoPickerDialog(viewModel, context),
        ),
      ],
    );
  }

  void _showCupertinoPickerDialog(
      MultiStatLineGraphModel viewModel, BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 300,
          color: kBackgroundColor,
          child: CupertinoPicker(
            backgroundColor: kBackgroundColor,
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              viewModel.setDisplayedStat(statOptions[index]);
            },
            children: statOptions.map((String value) {
              return Center(
                child: Text(
                  viewModel.getDisplayNameForStat(value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'DM Sans',
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  MultiStatLineGraphModel viewModelBuilder(BuildContext context) {
    final model = MultiStatLineGraphModel();
    model.initialize(statOptions);
    return model;
  }
}
