/// Sealed class hierarchy for GenUI chatbot conversation entries.
///
/// An entry is either a [GenuiUserEntry] (user's typed message) or
/// a [GenuiSurfaceEntry] (a GenUI surface rendered from Gemini's response).
sealed class GenuiConversationEntry {
  const GenuiConversationEntry({required this.timestamp});
  final DateTime timestamp;
}

/// A message typed by the user.
final class GenuiUserEntry extends GenuiConversationEntry {
  const GenuiUserEntry({required this.text, required super.timestamp});
  final String text;
}

/// A GenUI surface produced by Gemini.
final class GenuiSurfaceEntry extends GenuiConversationEntry {
  const GenuiSurfaceEntry({required this.surfaceId, required super.timestamp});

  /// The surface ID registered in the [SurfaceController].
  final String surfaceId;
}
