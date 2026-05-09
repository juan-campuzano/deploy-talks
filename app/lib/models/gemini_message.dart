enum GeminiRole { user, model }

class GeminiMessage {
  const GeminiMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  final GeminiRole role;
  final String text;
  final DateTime timestamp;
}
