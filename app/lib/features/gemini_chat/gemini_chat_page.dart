import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../enter_name/user_notifier.dart';
import 'gemini_chat_controller.dart';
import 'widgets/gemini_input_bar.dart';
import 'widgets/gemini_message_bubble.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});

  @override
  State<GeminiChatPage> createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage>
    with AutomaticKeepAliveClientMixin {
  late final GeminiChatController _controller;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final displayName =
        context.read<UserNotifier>().value?.displayName ?? 'Usuario';
    _controller = GeminiChatController(displayName: displayName);
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {});
    if (_controller.messages.isNotEmpty) {
      _scrollToBottom();
    }
    final error = _controller.error;
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
              ),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
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

  Future<void> _send() async {
    final text = _textController.text;
    if (text.trim().isEmpty || _controller.isLoading) return;
    _textController.clear();
    await _controller.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final messages = _controller.messages;
    final isLoading = _controller.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            border: Border(bottom: BorderSide(color: AppColors.border)),
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
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Gemini',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: messages.isEmpty
                        ? null
                        : _controller.clearSession,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: messages.isEmpty
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                    ),
                    tooltip: 'Limpiar conversación',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceEl,
              minHeight: 2,
            ),
          Expanded(
            child: messages.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        GeminiMessageBubble(message: messages[index]),
                  ),
          ),
          GeminiInputBar(
            controller: _textController,
            isLoading: isLoading,
            onSend: isLoading ? null : _send,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.textMuted, size: 36),
          SizedBox(height: 16),
          Text(
            'Pregúntale algo a Gemini ✨',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: AppColors.textMuted,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
