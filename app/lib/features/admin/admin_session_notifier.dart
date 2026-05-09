import 'package:flutter/foundation.dart';

class AdminSessionNotifier extends ValueNotifier<bool> {
  AdminSessionNotifier() : super(false);

  static const _adminPassword = String.fromEnvironment('ADMIN_PASSWORD');

  /// Returns true if authenticated successfully, false otherwise.
  bool authenticate(String password) {
    if (_adminPassword.isEmpty) return false;
    if (password == _adminPassword) {
      value = true;
      return true;
    }
    return false;
  }

  void logout() {
    value = false;
  }
}
