// lib/screens/users_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.watch(userServiceProvider);
    final chatService = ref.watch(chatServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ব্যবহারকারী তালিকা'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: userService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          // বর্তমান user কে তালিকা থেকে remove করুন
          final otherUsers = users.where((user) => user.uid != currentUser?.uid).toList();

          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final user = otherUsers[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(user.displayName?.substring(0, 1) ?? 'U')
                      : null,
                ),
                title: Text(user.displayName ?? 'No Name'),
                subtitle: Text(user.email ?? 'No Email'),
                onTap: () async {
                  // Chat তৈরি করুন বা open করুন
                  final chatId = await chatService.getOrCreateChat(
                      currentUser!.uid,
                      user.uid
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        otherUser: user,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}