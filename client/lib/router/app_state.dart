import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier {
  // int _bottomNavigatorIndex = 1; // 0: Orders, 1: Home, 2: Account
  // int get bottomNavigatorIndex => _bottomNavigatorIndex;
  // set bottomNavigatorIndex(int value) {
  //   _bottomNavigatorIndex = value;
  //   notifyListeners();
  // }

  bool _isShowCart = false;
  bool get isShowCart => _isShowCart;
  set isShowCart(bool value) {
    _isShowCart = value;
    notifyListeners();
  }

  // bool? _isOrderHistory;
  // bool? get isOrderHistory => _isOrderHistory;
  // set isOrderHistory(bool? value) {
  //   _isOrderHistory = value;
  //   notifyListeners();
  // }
}
