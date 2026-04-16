import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spot/core/utils.dart';

class GroupProvider extends ChangeNotifier {
  List _groupMembers = [];
  Set<String> _selectedUsers = {};
  int? _profileSelectedColorOption;
  XFile? _chooseImageFile;
  bool _isGroupNameError = false;
  String _selectedOption = 'All';

  List get groupMembers => _groupMembers;
  Set<String> get selectedUsers => _selectedUsers;
  int? get profileSelectedColorOption => _profileSelectedColorOption;
  XFile? get chooseImageFile => _chooseImageFile;
  bool get isGroupNameError => _isGroupNameError;
  String get selectedOption => _selectedOption;

  // *************** get user list *****************
  Future<void> selectedUserListData() async {
    try {
      String ids = _selectedUsers.join(',');
      final response = await CommonFunctions.getSelectedUserListData(ids);
      if (response.isNotEmpty) {
        _groupMembers = response;
        notifyListeners();
        // print("groupMembers-----------$groupMembers");
      }
    } catch (error) {
      // print("error while getting user chat list..... ${error}");
    }
  }

  // ****************** select group member ******************
  void selectMember(String userId) {
    if (_selectedUsers.contains(userId)) {
      _selectedUsers.remove(userId);
    } else {
      _selectedUsers.add(userId);
    }
    notifyListeners();
  }

  // ***************** remove group member **********************
  void removeUser(String userId) {
    _selectedUsers.remove(userId);
    _groupMembers.removeWhere((user) => user['iUserId'] == userId);
    notifyListeners();
  }

  // ***************** set group members and selected users *******************
  void setGroupMembers(List<Map<String, dynamic>> members) {
    _groupMembers = List.from(members);
    notifyListeners();
  }

  void setSelectedUsers(Set<String> users) {
    _selectedUsers = users;
    notifyListeners();
  }

  // ***************** clear all data ****************
  void clearGroupMembers() {
    _selectedUsers.clear();
    _groupMembers.clear();
    notifyListeners();
  }

  // ***************** set profile color option ****************
  void setProfileColorOption(int id) {
    _chooseImageFile = null;
    _profileSelectedColorOption = id;
    notifyListeners();
  }

  // ***************** remove profile color option ****************
  void removeProfileColorOption() {
    _profileSelectedColorOption = null;
    notifyListeners();
  }

  // ***************** set choose profile ****************
  void setChooseProfile(XFile imageFile) {
    _profileSelectedColorOption = null;
    _chooseImageFile = imageFile;
    notifyListeners();
  }

  // ***************** remove profile ****************
  void clearChoosedProfile() {
    _chooseImageFile = null;
    notifyListeners();
  }

  void clearProfile() {
    _profileSelectedColorOption = null;
    _chooseImageFile = null;
    notifyListeners();
  }

  // ***************** set is group name Error *******************
  void setGroupNameError(bool value) {
    _isGroupNameError = value;
    notifyListeners();
  }

  // ***************** set is group chat permission selection *******************
  void setSelectedOption(String value) {
    _selectedOption = value;
    notifyListeners();
  }
}
