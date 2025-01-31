import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  String _argument = '';

  String get argument => _argument;

  void setArgument(String argument) {
    _argument = argument;
    notifyListeners();
  }

  void resetArgument() {
    _argument = '';
    notifyListeners();
  }
}
