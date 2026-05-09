import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/chat_message.dart';

class ChatService {
  ChatService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection('messages');

  Future<void> sendMessage(AppUser user, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _messages.add(
      ChatMessage(
        id: '',
        senderId: user.uid,
        senderName: user.displayName,
        sessionId: user.sessionId,
        text: trimmed,
        timestamp: DateTime.now(),
        roomId: 'public',
      ).toMap(),
    );
  }

  Stream<List<ChatMessage>> messagesStream(String roomId) {
    return _messages
        .where('roomId', isEqualTo: roomId)
        .orderBy('timestamp', descending: false)
        .limit(500)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(ChatMessage.fromFirestore).toList(),
        );
  }
}
