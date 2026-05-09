import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/chat_item.dart';
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
    final items = controller.orderedItems;
    final isLoading = controller.isLoadingHistory;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    final hasMessages = items.any((i) => i is MessageItem);

    if (!hasMessages && items.isEmpty) {
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
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return switch (item) {
          MessageItem(:final surfaceId) => GenuiBubble(
            surfaceId: surfaceId,
            controller: genuiService.controller,
          ),
          SystemEventItem(:final text) => _SystemEventTile(text: text),
        };
      },
    );
  }
}

class _SystemEventTile extends StatelessWidget {
  const _SystemEventTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            color: AppColors.textMuted,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
