import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class UserAvatarModel extends BaseViewModel {
  late final String _username;

  void initialize(String username) {
    this._username = username;
  }

  String getInitial() {
    return _username.isNotEmpty ? _username[0].toUpperCase() : '?';
  }

  Color generateColorFromString(String str) {
    // Generate a consistent color for the same username
    int hash = str.codeUnits.fold(0, (prev, curr) => prev + curr);
    // Use predefined material colors for better aesthetics
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[hash % colors.length];
  }
}
