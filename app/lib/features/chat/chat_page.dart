import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enter_name/user_notifier.dart';
import '../../services/chat_service.dart';
import '../../services/genui_service.dart';
import 'chat_controller.dart';
import 'widgets/chat_list.dart';
import 'widgets/message_input.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

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
              title: const Text('Deploy Talks Chat'),
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
