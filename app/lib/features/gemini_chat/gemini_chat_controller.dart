import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../models/gemini_message.dart';

class GeminiChatController extends ChangeNotifier {
  GeminiChatController({required String displayName}) {
    _model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
        'Eres un asistente amigable llamado Gemini. '
        'El usuario se llama $displayName. '
        'Responde de forma concisa y útil.',
      ),
    );
    _session = _model.startChat();
  }

  late final GenerativeModel _model;
  late ChatSession _session;

  final List<GeminiMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<GeminiMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _messages.add(
      GeminiMessage(
        role: GeminiRole.user,
        text: trimmed,
        timestamp: DateTime.now(),
      ),
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _session.sendMessage(Content.text(trimmed));
      final reply = response.text?.trim();
      _messages.add(
        GeminiMessage(
          role: GeminiRole.model,
          text: reply?.isNotEmpty == true
              ? reply!
              : 'No se recibió respuesta, intenta de nuevo.',
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _error = 'Error al contactar a Gemini. Intenta de nuevo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSession() {
    _messages.clear();
    _session = _model.startChat();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
