import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_background.dart';
import '../../services/admin_service.dart';
import '../../services/chat_service.dart';
import '../../services/genui_service.dart';
import '../../services/presence_service.dart';
import '../../theme.dart';
import '../enter_name/user_notifier.dart';
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
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _presenceService = context.read<PresenceService>();
    final user = context.read<UserNotifier>().value!;
    _sessionId = user.sessionId;
    _presenceService.join(sessionId: _sessionId, displayName: user.displayName);

    // Keep presence alive with a periodic heartbeat every 30s.
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _presenceService.heartbeat(_sessionId),
    );
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _presenceService.leave(_sessionId);
    super.dispose();
  }

  Widget _buildBackground(ChatBackground bg, Widget child) {
    final colors = bg.colors
        .map((hex) => Color(int.parse(hex.replaceFirst('#', '0xFF'))))
        .toList();

    return Stack(
      children: [
        // Gradient layer
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                transform: GradientRotation(bg.angle * 3.14159 / 180),
              ),
            ),
          ),
        ),
        // Emoji decoration layer
        ...bg.decorations.map(
          (d) => Positioned(
            left: null,
            top: null,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
              child: Align(
                alignment: Alignment(d.x * 2 - 1, d.y * 2 - 1),
                child: Text(d.symbol, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ),
        // Chat content on top
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = context.read<UserNotifier>();
    final chatService = context.read<ChatService>();
    final genuiService = context.read<GenuiService>();
    final adminService = context.read<AdminService>();
    final currentUser = userNotifier.value!;

    return ChangeNotifierProvider(
      create: (_) => ChatController(
        chatService: chatService,
        genuiService: genuiService,
        currentUser: currentUser,
      ),
      child: Builder(
        builder: (context) {
          return StreamBuilder<ChatBackground?>(
            stream: adminService.backgroundStream(),
            builder: (context, bgSnapshot) {
              final background = bgSnapshot.data;
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.bg,
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.rocket_launch_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StreamBuilder<int>(
                                stream: _presenceService.activeCountStream(),
                                builder: (context, snapshot) {
                                  final count = snapshot.data ?? 0;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Deploy Talks',
                                        style: TextStyle(
                                          fontFamily: 'Syne',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (count > 0)
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '$count ${count == 1 ? 'persona' : 'personas'} conectadas',
                                              style: const TextStyle(
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => userNotifier.clearUser(),
                              icon: const Icon(
                                Icons.logout_rounded,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              label: const Text(
                                'Salir',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                body: Builder(
                  builder: (context) {
                    final chatContent = Column(
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
                    );
                    if (background == null || background.colors.isEmpty) {
                      return chatContent;
                    }
                    return _buildBackground(background, chatContent);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
