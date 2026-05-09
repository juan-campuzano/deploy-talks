import 'package:cloud_firestore/cloud_firestore.dart';

class BgDecoration {
  const BgDecoration({required this.symbol, required this.x, required this.y});

  final String symbol;
  final double x; // 0.0 – 1.0 (fracción del ancho)
  final double y; // 0.0 – 1.0 (fracción del alto)

  factory BgDecoration.fromMap(Map<String, dynamic> m) => BgDecoration(
    symbol: m['symbol'] as String,
    x: (m['x'] as num).toDouble(),
    y: (m['y'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {'symbol': symbol, 'x': x, 'y': y};
}

class ChatBackground {
  const ChatBackground({
    required this.colors,
    required this.angle,
    required this.label,
    required this.prompt,
    required this.updatedAt,
    this.decorations = const [],
  });

  final List<String> colors;
  final int angle;
  final String label;
  final String prompt;
  final DateTime updatedAt;
  final List<BgDecoration> decorations;

  factory ChatBackground.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawDecs = data['decorations'] as List? ?? [];
    return ChatBackground(
      colors: List<String>.from(data['colors'] as List),
      angle: (data['angle'] as num).toInt(),
      label: data['label'] as String,
      prompt: data['prompt'] as String,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      decorations: rawDecs
          .cast<Map<String, dynamic>>()
          .map(BgDecoration.fromMap)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'colors': colors,
    'angle': angle,
    'label': label,
    'prompt': prompt,
    'updatedAt': Timestamp.fromDate(updatedAt),
    'decorations': decorations.map((d) => d.toMap()).toList(),
  };
}
