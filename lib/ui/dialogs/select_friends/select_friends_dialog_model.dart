import 'package:habitur/models/user.dart';
import 'package:stacked/stacked.dart';

class SelectFriendsDialogModel extends BaseViewModel {
  List<UserModel> _friends = [];
  List<UserModel> get friends => _friends;

  List<UserModel> _selectedFriends = [];
  List<UserModel> get selectedFriends => _selectedFriends;

  void init(List<UserModel> friends) {
    _friends = friends;
    notifyListeners();
  }

  void setSelectedFriends(List<UserModel> selectedFriends) {
    _selectedFriends = selectedFriends;
    notifyListeners();
  }
}
