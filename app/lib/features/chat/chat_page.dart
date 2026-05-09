import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enter_name/user_notifier.dart';
import '../../services/chat_service.dart';
import '../../services/genui_service.dart';
import '../../services/presence_service.dart';
import 'chat_controller.dart';
import 'widgets/chat_list.dart';
import 'widgets/message_input.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final PresenceService _presenceService;
  late final String _sessionId;

  @override
  void initState() {
    super.initState();
    _presenceService = context.read<PresenceService>();
    final user = context.read<UserNotifier>().value!;
    _sessionId = user.sessionId;
    _presenceService.join(sessionId: _sessionId, displayName: user.displayName);
  }

  @override
  void dispose() {
    _presenceService.leave(_sessionId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = context.read<UserNotifier>();
    final chatService = context.read<ChatService>();
    final genuiService = context.read<GenuiService>();
    final currentUser = userNotifier.value!;

    return ChangeNotifierProvider(
      create: (_) => ChatController(
        chatService: chatService,
        genuiService: genuiService,
        currentUser: currentUser,
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: StreamBuilder<int>(
                stream: _presenceService.activeCountStream(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Deploy Talks Chat'),
                      if (count > 0)
                        Text(
                          '$count ${count == 1 ? 'persona' : 'personas'} en el chat',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => userNotifier.clearUser(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Salir'),
                ),
              ],
            ),
            body: Column(
              children: [
                const Expanded(child: ChatList()),
                MessageInput(
                  chatService: chatService,
                  currentUser: currentUser,
                  onError: (error) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
