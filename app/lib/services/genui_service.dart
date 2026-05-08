import 'package:genui/genui.dart';

import '../models/chat_message.dart' as app_model;

class GenuiService {
  GenuiService({required this.catalog}) {
    _transport = A2uiTransportAdapter();
    _controller = SurfaceController(catalogs: [catalog]);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );
  }

  final Catalog catalog;
  late final A2uiTransportAdapter _transport;
  late final SurfaceController _controller;
  late final Conversation _conversation;

  SurfaceController get controller => _controller;

  /// Renders [chatMessage] as a gen_ui surface by injecting A2UI messages
  /// directly — no LLM round-trip needed for deterministic chat bubbles.
  String renderMessageAsBubble(app_model.ChatMessage chatMessage, bool isOwn) {
    final surfaceId = 'msg-${chatMessage.id}';

    _transport.addMessage(
      CreateSurface(surfaceId: surfaceId, catalogId: catalog.catalogId ?? ''),
    );

    _transport.addMessage(
      UpdateComponents(
        surfaceId: surfaceId,
        components: [
          Component(
            id: 'root',
            type: 'ChatBubble',
            properties: {
              'content': chatMessage.text,
              'senderName': chatMessage.senderName,
              'isOwn': isOwn,
            },
          ),
        ],
      ),
    );

    return surfaceId;
  }

  void dispose() {
    _conversation.dispose();
    _transport.dispose();
  }
}
