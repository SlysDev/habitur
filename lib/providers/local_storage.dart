import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage extends ChangeNotifier {
  void initializeStorage() async {
    var habitsBox = await Hive.openBox('habits_storage');
  }
}
