// lib/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}