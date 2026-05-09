import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme.dart';
import '../chat_controller.dart';
import '../../../services/genui_service.dart';
import 'genui_bubble.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    final genuiService = context.read<GenuiService>();
    final surfaceIds = controller.orderedSurfaceIds;
    final isLoading = controller.isLoadingHistory;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (surfaceIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceEl,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sé el primero en enviar un mensaje',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    _scrollToBottom();

    return ListView.builder(
      controller: _scrollController,
      itemCount: surfaceIds.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return GenuiBubble(
          surfaceId: surfaceIds[index],
          controller: genuiService.controller,
        );
      },
    );
  }
}
