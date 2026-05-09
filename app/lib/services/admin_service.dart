import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../models/chat_background.dart';

class GeminiParseException implements Exception {
  GeminiParseException(this.message);
  final String message;
  @override
  String toString() => 'GeminiParseException: $message';
}

class AdminService {
  AdminService(this._firestore)
    : _model = FirebaseAI.vertexAI().generativeModel(model: 'gemini-2.5-flash');

  final FirebaseFirestore _firestore;
  final GenerativeModel _model;

  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection('messages');

  DocumentReference<Map<String, dynamic>> get _backgroundDoc =>
      _firestore.collection('settings').doc('chat_background');

  /// Deletes all messages in [roomId] using batch operations.
  Future<void> clearChat({String roomId = 'public'}) async {
    QuerySnapshot snapshot;
    do {
      snapshot = await _messages
          .where('roomId', isEqualTo: roomId)
          .limit(500)
          .get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snapshot.docs.length == 500);
  }

  /// Sends [userPrompt] to Gemini and persists the result to Firestore.
  Future<ChatBackground> generateBackground(String userPrompt) async {
    final prompt =
        '''
The user wants a chat background with the following description: "$userPrompt".
Respond ONLY with a valid JSON object in this exact format, no markdown, no explanation:
{
  "colors": ["#hexcolor1", "#hexcolor2"],
  "angle": 135,
  "label": "Short description in Spanish",
  "decorations": [
    {"symbol": "⭐", "x": 0.1, "y": 0.05},
    {"symbol": "🌙", "x": 0.85, "y": 0.15}
  ]
}
Rules:
- colors: array of 2 to 4 hex color strings matching the theme
- angle: gradient rotation in degrees (0-360)
- label: short human-readable description in Spanish (max 30 chars)
- decorations: array of 6 to 12 emoji elements that visually represent the theme (stars, planets, clouds, etc.)
  - symbol: a single emoji character
  - x: horizontal position from 0.0 (left) to 1.0 (right)
  - y: vertical position from 0.0 (top) to 1.0 (bottom)
  - Distribute them across the whole background (vary both x and y)
  - If the theme has no obvious decorative elements, use abstract shapes (✦ ◆ ○ ● ◇)
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';

    Map<String, dynamic> json;
    try {
      // Strip markdown code fences if present
      final cleaned = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      json = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      throw GeminiParseException('Could not parse Gemini response: $text');
    }

    final colors = (json['colors'] as List?)?.cast<String>();
    final angle = (json['angle'] as num?)?.toInt();
    final label = json['label'] as String?;

    if (colors == null || colors.length < 2 || angle == null || label == null) {
      throw GeminiParseException('Invalid schema in Gemini response: $json');
    }

    final rawDecs = (json['decorations'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(BgDecoration.fromMap)
        .toList();

    final background = ChatBackground(
      colors: colors,
      angle: angle,
      label: label,
      prompt: userPrompt,
      updatedAt: DateTime.now(),
      decorations: rawDecs,
    );

    await _backgroundDoc.set(background.toMap());
    return background;
  }

  /// Stream of the active chat background. Emits null if no background is set.
  Stream<ChatBackground?> backgroundStream() {
    return _backgroundDoc.snapshots().map((snap) {
      if (!snap.exists) return null;
      return ChatBackground.fromFirestore(snap);
    });
  }
}
