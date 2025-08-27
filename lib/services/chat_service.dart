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

  Future<String> getOrCreateChat(String user1Id, String user2Id) async {
    // user1Id এবং user2Id কে sort করুন যাতে একই chat জন্য একই ID হয়
    final sortedIds = [user1Id, user2Id]..sort();
    final chatId = '${sortedIds[0]}_${sortedIds[1]}';

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'user1Id': sortedIds[0],
        'user2Id': sortedIds[1],
        'createdAt': Timestamp.now(),
      });
    }

    return chatId;
  }

  // নির্দিষ্ট chat এর messages stream পান
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // একটি message পাঠান
  Future<void> sendMessage(String chatId, String text, String senderId) async {
    await _firestore.collection('messages').add({
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
    });
  }

  // সব chats পান (user list দেখানোর জন্য)
  Stream<List<Chat>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('user1Id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}