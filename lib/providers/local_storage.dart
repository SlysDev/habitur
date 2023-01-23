// TODO: Add local storage management Hive. Store and modify habits array  <22-12-22, slys> //
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage extends ChangeNotifier {
  void initializeStorage() {
    Hive.openBox('habits_storage');
  }
}
