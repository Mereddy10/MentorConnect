import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  static int? currentUserId; // ✅ Static variable to hold current user ID

  int? get userId => currentUserId; // Optional getter if needed elsewhere

  void login(String userId) {
    currentUserId = int.tryParse(userId); // ✅ Convert string to int safely
    notifyListeners();
  }

  void logout() {
    currentUserId = null;
    notifyListeners();
  }
}
