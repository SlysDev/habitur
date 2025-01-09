import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/user.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SelectFriendsDialogModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
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

  void closeDialog({bool friendsSelected = false}) {
    _dialogService.completeDialog(DialogResponse(confirmed: friendsSelected));
  }
}
