// lib/models/chat_model.dart

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class Chat {
  final String chatId;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;

  Chat({
    required this.chatId,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
  });

  factory Chat.fromMap(Map<String, dynamic> map, String id) {
    return Chat(
      chatId: id,
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}