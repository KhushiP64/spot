import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  int _selectedStatusId = 0;

  int get selectedStatusId => _selectedStatusId;

  // ************ handle set selected status id *****************
  void setSelectedStatusId(int id) {
    _selectedStatusId = id;
    notifyListeners();
  }

  void removeSelectedStatusId() {
    _selectedStatusId = 0;
    notifyListeners();
  }
}
