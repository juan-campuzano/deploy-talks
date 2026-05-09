import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/presence_record.dart';

/// Presence documents expire after this duration without a heartbeat.
const _kPresenceTtl = Duration(seconds: 90);

class PresenceService {
  PresenceService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _presence =>
      _firestore.collection('presence');

  /// Registers the current session in the presence collection.
  Future<void> join({required String sessionId, required String displayName}) {
    return _presence.doc(sessionId).set({
      'displayName': displayName,
      'joinedAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Updates lastSeen so the session is considered alive.
  Future<void> heartbeat(String sessionId) {
    return _presence.doc(sessionId).update({
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Removes the current session from the presence collection.
  Future<void> leave(String sessionId) {
    return _presence.doc(sessionId).delete();
  }

  /// Stream of the number of users currently alive (lastSeen within TTL).
  Stream<int> activeCountStream() {
    final cutoff = Timestamp.fromDate(DateTime.now().subtract(_kPresenceTtl));
    return _presence
        .where('lastSeen', isGreaterThan: cutoff)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// Stream of all connected users ordered by joinedAt ascending,
  /// filtering out sessions whose lastSeen is older than [_kPresenceTtl].
  Stream<List<PresenceRecord>> connectedUsersStream() {
    return _presence.orderBy('joinedAt').snapshots().map((s) {
      final cutoff = DateTime.now().subtract(_kPresenceTtl);
      return s.docs
          .where((doc) {
            final ts = doc.data()['lastSeen'] as Timestamp?;
            if (ts == null) return false;
            return ts.toDate().isAfter(cutoff);
          })
          .map(PresenceRecord.fromFirestore)
          .toList();
    });
  }
}
