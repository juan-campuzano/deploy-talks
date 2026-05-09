import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../services/genui_service.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required this.chatService,
    required this.genuiService,
    required this.currentUser,
  }) {
    _init();
  }

  final ChatService chatService;
  final GenuiService genuiService;
  final AppUser currentUser;

  /// Maps message ID → surfaceId returned by gen_ui
  final Map<String, String> _messageIdToSurfaceId = {};

  /// Ordered list of surfaceIds for rendering
  final List<String> _orderedSurfaceIds = [];

  /// Set to track already-processed message IDs (avoids duplicates)
  final Set<String> _processedMessageIds = {};

  bool _isLoadingHistory = true;
  StreamSubscription<List<ChatMessage>>? _subscription;

  List<String> get orderedSurfaceIds => List.unmodifiable(_orderedSurfaceIds);
  bool get isLoadingHistory => _isLoadingHistory;

  void _init() {
    _subscription = chatService
        .messagesStream('public')
        .listen(
          _onMessages,
          onError: (_) {
            _isLoadingHistory = false;
            notifyListeners();
          },
        );
  }

  Future<void> _onMessages(List<ChatMessage> messages) async {
    bool didChange = false;

    for (final msg in messages) {
      if (_processedMessageIds.contains(msg.id)) continue;
      _processedMessageIds.add(msg.id);

      final isOwn = msg.sessionId == currentUser.sessionId;
      final surfaceId = genuiService.renderMessageAsBubble(msg, isOwn);
      _messageIdToSurfaceId[msg.id] = surfaceId;
      _orderedSurfaceIds.add(surfaceId);
      didChange = true;
    }

    if (_isLoadingHistory) {
      _isLoadingHistory = false;
      didChange = true;
    }

    if (didChange) notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
