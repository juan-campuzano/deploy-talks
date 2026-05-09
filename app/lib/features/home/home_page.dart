import 'package:flutter/material.dart';

import '../../theme.dart';
import '../chat/chat_page.dart';
import '../gemini_chat/gemini_chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: AppColors.bg,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Chat Grupal'),
              Tab(text: 'Gemini'),
            ],
          ),
        ),
        body: const TabBarView(children: [ChatPage(), GeminiChatPage()]),
      ),
    );
  }
}
