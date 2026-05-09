import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';

/// Global source-of-truth for the current user session.
///
/// Uses [ValueNotifier] so any widget can listen via [ValueListenableBuilder].
class UserNotifier extends ValueNotifier<AppUser?> {
  UserNotifier(this._auth) : super(null);

  final FirebaseAuth _auth;

  /// Unique ID for this browser tab / app instance.
  /// Generated once in memory so it is never shared across tabs or page reloads,
  /// ensuring that `isOwn` comparisons work correctly even when multiple tabs
  /// share the same Firebase Anonymous Auth UID.
  final String _sessionId = _generateSessionId();

  static String _generateSessionId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random.secure();
    return List.generate(20, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// Signs in anonymously and stores the user with the given [displayName].
  Future<void> setUser(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) throw ArgumentError('displayName must not be empty');

    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    final uid = _auth.currentUser!.uid;
    value = AppUser(uid: uid, displayName: trimmed, sessionId: _sessionId);
  }

  /// Clears the current user session without signing out of Firebase Auth.
  ///
  /// Firebase Anonymous Auth is shared across all browser tabs; calling
  /// signOut() would revoke authentication for every open tab. Instead we
  /// only clear the local AppUser state so the router redirects to /enter-name.
  Future<void> clearUser() async {
    value = null;
  }
}
