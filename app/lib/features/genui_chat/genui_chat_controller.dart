import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';

import '../../models/genui_conversation_entry.dart';
import 'catalog/genui_chatbot_catalog.dart';

/// Normalizes any A2UI chunk to use the correct catalog ID.
///
/// Gemini sometimes generates a UUID instead of the expected catalog ID.
/// This function replaces any `catalogId` value in the JSON payload with
/// [kGenuiChatbotCatalogId] before the chunk is parsed by the transport.
String _normalizeCatalogId(String chunk) {
  try {
    // Only process chunks that contain a catalogId field
    if (!chunk.contains('"catalogId"')) return chunk;

    // Replace any value for catalogId with the correct one
    return chunk.replaceAllMapped(
      RegExp(r'"catalogId"\s*:\s*"[^"]*"'),
      (_) => '"catalogId": "$kGenuiChatbotCatalogId"',
    );
  } catch (_) {
    return chunk;
  }
}

class GenuiChatController extends ChangeNotifier {
  GenuiChatController({required String displayName}) {
    _catalog = buildGenuiChatbotCatalog();
    _transport = A2uiTransportAdapter();
    _surfaceController = SurfaceController(catalogs: [_catalog]);
    _conversation = Conversation(
      controller: _surfaceController,
      transport: _transport,
    );

    final promptBuilder = PromptBuilder.chat(catalog: _catalog);
    final systemPrompt = [
      'Eres un asistente útil y amigable. El usuario se llama $displayName.',
      ...promptBuilder.systemPrompt(),
    ].join('\n\n');

    _model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(systemPrompt),
    );
    _session = _model.startChat();

    _conversationSubscription = _conversation.events.listen((event) {
      if (event is ConversationSurfaceAdded) {
        _entries.add(
          GenuiSurfaceEntry(
            surfaceId: event.surfaceId,
            timestamp: DateTime.now(),
          ),
        );
        notifyListeners();
      }
    });
  }

  late Catalog _catalog;
  late A2uiTransportAdapter _transport;
  late SurfaceController _surfaceController;
  late Conversation _conversation;
  late StreamSubscription<ConversationEvent> _conversationSubscription;
  late final GenerativeModel _model;
  late ChatSession _session;

  final List<GenuiConversationEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<GenuiConversationEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get error => _error;
  SurfaceController get surfaceController => _surfaceController;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _entries.add(GenuiUserEntry(text: trimmed, timestamp: DateTime.now()));
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _session.sendMessage(Content.text(trimmed));
      final responseText = response.text ?? '';
      if (responseText.isNotEmpty) {
        _transport.addChunk(_normalizeCatalogId(responseText));
      }
    } catch (e) {
      _error = 'Error al contactar a Gemini. Intenta de nuevo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSession() {
    _conversationSubscription.cancel();
    _conversation.dispose();
    _transport.dispose();

    _transport = A2uiTransportAdapter();
    _surfaceController = SurfaceController(catalogs: [_catalog]);
    _conversation = Conversation(
      controller: _surfaceController,
      transport: _transport,
    );
    _conversationSubscription = _conversation.events.listen((event) {
      if (event is ConversationSurfaceAdded) {
        _entries.add(
          GenuiSurfaceEntry(
            surfaceId: event.surfaceId,
            timestamp: DateTime.now(),
          ),
        );
        notifyListeners();
      }
    });

    _session = _model.startChat();
    _entries.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _conversationSubscription.cancel();
    _conversation.dispose();
    _transport.dispose();
    super.dispose();
  }
}
