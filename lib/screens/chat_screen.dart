import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ref.watch(chatServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {
              authService.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatService.getMessages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isme = message.senderId == user?.uid;
                    return ListTile(
                      title: Align(
                        alignment: isme
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isme ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isme ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment: isme
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          '${message.timestamp.hour}:${message.timestamp.minute}',
                          style: const TextStyle(fontSize: 12),
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
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (messageController.text.trim().isNotEmpty &&
                        user != null) {
                      await chatService.sendMessage(
                        messageController.text.trim(),
                        user.uid,
                      );
                      messageController.clear();
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
