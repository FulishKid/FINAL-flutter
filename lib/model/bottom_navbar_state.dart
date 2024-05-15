// ignore_for_file: unused_element

import 'package:flutter/material.dart';

class BottomNavBarModel extends ChangeNotifier {
  int _state = 0;

  int get state => _state;

  void changeIndexState(int index) {
    _state = index;
    notifyListeners();
  }
}
