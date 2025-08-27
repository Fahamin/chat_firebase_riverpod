// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('চ্যাট অ্যাপে স্বাগতম'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await authService.signInWithGoogle();
          },
          child: const Text('Google Sing In'),
        ),
      ),
    );
  }
}