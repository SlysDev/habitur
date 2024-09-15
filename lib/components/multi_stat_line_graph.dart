import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/stat_point.dart';

class MultiStatLineGraph extends StatefulWidget {
  MultiStatLineGraph(
      {required this.data,
      this.height = 200,
      this.width = 400,
      this.showDots = true,
      this.showStatTitle = false,
      this.showChangeIndicator = false,
      super.key});

  final List<StatPoint> data;
  double height;
  double width;
  bool showDots;
  bool showStatTitle;
  bool showChangeIndicator;

  @override
  State<MultiStatLineGraph> createState() => _MultiStatLineGraphState();
}

class _MultiStatLineGraphState extends State<MultiStatLineGraph> {
  String displayedStat = 'Confidence level'; // Initial stat

  // List of available stats
  final List<String> statOptions = [
    'Confidence level',
    'Difficulty',
    'Consistency',
    'Completions',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kIsWeb
              ? _buildDropdown()
              : Platform.isIOS
                  ? _buildCupertinoPicker()
                  : _buildDropdown(),
          // Dropdown for selecting the stat
          const SizedBox(height: 16), // Spacing between dropdown and graph

          // Line graph based on the selected stat
          Flexible(
            fit: FlexFit.loose,
            child: LineGraph(
              data: widget.data,
              width: widget.width,
              height: widget.height,
              statName: displayedStat == 'Confidence level'
                  ? 'confidenceLevel'
                  : displayedStat == 'Difficulty'
                      ? 'difficultyRating'
                      : displayedStat == 'Consistency'
                          ? 'consistencyFactor'
                          : 'completions',
              showDots: widget.showDots,
              showChangeIndicator: widget.showChangeIndicator,
              showStatTitle: widget.showStatTitle,
            ),
          ),
        ],
      ),
    );
  }

// Material Dropdown (for Android)
  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kFadedBlue, // Dark primary from style guide
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: displayedStat,
        icon: const Icon(Icons.arrow_downward_rounded, color: Colors.white),
        elevation: 0,
        dropdownColor: kFadedBlue, // Faded blue
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'DM Sans',
          fontSize: 16,
        ),
        underline: Container(),
        onChanged: (String? newValue) {
          setState(() {
            displayedStat = newValue!;
          });
        },
        items: statOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

// Cupertino Picker (for iOS)
  Widget _buildCupertinoPicker() {
    return Stack(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kFadedBlue, // Dark primary from style guide
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayedStat,
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
          onPressed: () => _showCupertinoPickerDialog(),
        ),
      ],
    );
  }

  // Show CupertinoPicker in a dialog
  void _showCupertinoPickerDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 300,
          color: kBackgroundColor, // Background color
          child: CupertinoPicker(
            backgroundColor: kBackgroundColor, // Dark primary from style guide
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                displayedStat = statOptions[index];
              });
            },
            children: statOptions.map((String value) {
              return Center(
                child: Text(
                  value,
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
}
