import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../enter_name/user_notifier.dart';
import '../gemini_chat/widgets/gemini_input_bar.dart';
import '../../models/genui_conversation_entry.dart';
import 'genui_chat_controller.dart';
import 'widgets/genui_user_bubble.dart';

class GenuiChatPage extends StatefulWidget {
  const GenuiChatPage({super.key});

  @override
  State<GenuiChatPage> createState() => _GenuiChatPageState();
}

class _GenuiChatPageState extends State<GenuiChatPage>
    with AutomaticKeepAliveClientMixin {
  late final GenuiChatController _controller;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final displayName =
        context.read<UserNotifier>().value?.displayName ?? 'Usuario';
    _controller = GenuiChatController(displayName: displayName);
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
    if (_controller.entries.isNotEmpty) {
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
    final entries = _controller.entries;
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
                      Icons.auto_awesome_mosaic,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'GenUI',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: entries.isEmpty
                        ? null
                        : _controller.clearSession,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: entries.isEmpty
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
            child: entries.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return switch (entry) {
                        GenuiUserEntry(:final text) => GenuiUserBubble(
                          text: text,
                        ),
                        GenuiSurfaceEntry(:final surfaceId) => Align(
                          alignment: Alignment.centerLeft,
                          child: Surface(
                            surfaceContext: _controller.surfaceController
                                .contextFor(surfaceId),
                            defaultBuilder: (_) => const SizedBox.shrink(),
                          ),
                        ),
                      };
                    },
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
          Icon(Icons.auto_awesome_mosaic, color: AppColors.textMuted, size: 36),
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
