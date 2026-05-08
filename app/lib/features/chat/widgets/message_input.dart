import 'package:flutter/material.dart';

import '../../../models/app_user.dart';
import '../../../services/chat_service.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.chatService,
    required this.currentUser,
    this.onError,
  });

  final ChatService chatService;
  final AppUser currentUser;
  final void Function(String error)? onError;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend => !_sending && _controller.text.trim().isNotEmpty;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await widget.chatService.sendMessage(widget.currentUser, text);
      _controller.clear();
    } catch (e) {
      widget.onError?.call('Error al enviar el mensaje. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _canSend ? _send() : null,
              onChanged: (_) => setState(() {}),
              enabled: !_sending,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _canSend ? _send : null,
            icon: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
