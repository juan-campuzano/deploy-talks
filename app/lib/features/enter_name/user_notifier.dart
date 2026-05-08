import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';

/// Global source-of-truth for the current user session.
///
/// Uses [ValueNotifier] so any widget can listen via [ValueListenableBuilder].
class UserNotifier extends ValueNotifier<AppUser?> {
  UserNotifier(this._auth) : super(null);

  final FirebaseAuth _auth;

  /// Signs in anonymously and stores the user with the given [displayName].
  Future<void> setUser(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) throw ArgumentError('displayName must not be empty');

    UserCredential credential;
    if (_auth.currentUser != null) {
      credential = await _auth.signInAnonymously();
    } else {
      credential = await _auth.signInAnonymously();
    }

    final uid = credential.user!.uid;
    value = AppUser(uid: uid, displayName: trimmed);
  }

  /// Signs out and clears the current user.
  Future<void> clearUser() async {
    await _auth.signOut();
    value = null;
  }
}
