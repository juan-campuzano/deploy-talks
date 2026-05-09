import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.sessionId,
    required this.text,
    required this.timestamp,
    required this.roomId,
  });

  final String id;
  final String senderId;
  final String senderName;

  /// Per-tab session ID. Used client-side to compute `isOwn`.
  final String sessionId;

  final String text;
  final DateTime timestamp;
  final String roomId;

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      sessionId: (data['sessionId'] as String?) ?? data['senderId'] as String,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      roomId: data['roomId'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'senderName': senderName,
    'sessionId': sessionId,
    'text': text,
    'timestamp': Timestamp.fromDate(timestamp),
    'roomId': roomId,
  };
}
