class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.sessionId,
  });

  final String uid;
  final String displayName;

  /// Unique ID for this browser tab / app instance (generated in memory).
  /// Used to distinguish "own" messages from received ones, since Anonymous
  /// Auth shares the same UID across browser tabs in the same browser.
  final String sessionId;
}
