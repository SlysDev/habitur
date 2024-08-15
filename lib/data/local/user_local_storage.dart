import 'package:flutter/material.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class UserLocalStorage extends ChangeNotifier {
  dynamic _userBox;

  Future<void> init() async {
    if (Hive.isBoxOpen('user')) {
      print('userBox is open');
      _userBox = Hive.box<UserModel>('user');
    } else {
      print('userBox must be newly opened');
      _userBox = await Hive.openBox<UserModel>('user');
    }
  }

  Future<void> loadData(BuildContext context) async {
    await init(); // may need, may not
    if (_userBox.values.toList().isNotEmpty) {
      Provider.of<UserData>(context, listen: false).currentUser =
          _userBox.getAt(0);
    }
  }

  Future<void> saveData(BuildContext context) async {
    _userBox.putAt(
        0, Provider.of<UserData>(context, listen: false).currentUser);
  }
}
