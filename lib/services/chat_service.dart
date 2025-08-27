// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../providers/firebase_providers.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.read(firestoreProvider));
});

class ChatService {
  final FirebaseFirestore _firestore;

  ChatService(this._firestore);

  // Get messages stream
  Stream<List<Message>> getMessages() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Send a message
  Future<void> sendMessage(String text, String senderId) async {
    await _firestore.collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
    });
  }
}