// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final AppUser otherUser;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ref.watch(chatServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.displayName ?? 'Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.uid;

                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          '${message.timestamp.hour}:${message.timestamp.minute}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'মেসেজ লিখুন...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.trim().isNotEmpty && currentUser != null) {
                      await chatService.sendMessage(
                        widget.chatId,
                        _messageController.text.trim(),
                        currentUser.uid,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}