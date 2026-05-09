import 'package:cloud_firestore/cloud_firestore.dart';

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
    });
  }

  /// Removes the current session from the presence collection.
  Future<void> leave(String sessionId) {
    return _presence.doc(sessionId).delete();
  }

  /// Stream of the number of users currently in the chat.
  Stream<int> activeCountStream() {
    return _presence.snapshots().map((s) => s.docs.length);
  }
}
