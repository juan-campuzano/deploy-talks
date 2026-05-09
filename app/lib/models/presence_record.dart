import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceRecord {
  const PresenceRecord({
    required this.sessionId,
    required this.displayName,
    required this.joinedAt,
  });

  final String sessionId;
  final String displayName;
  final DateTime joinedAt;

  factory PresenceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PresenceRecord(
      sessionId: doc.id,
      displayName: data['displayName'] as String,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
