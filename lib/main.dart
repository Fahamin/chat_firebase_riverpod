import 'package:chat_firebase/providers/firebase_providers.dart';
import 'package:chat_firebase/screens/chat_screen.dart';
import 'package:chat_firebase/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInitialization = ref.watch(firebaseInitializationProvider);
    final currentUser = ref.watch(currentUserProvider);
    return MaterialApp(
      title: 'Flutter Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: firebaseInitialization.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) =>
            Scaffold(body: Center(child: Text('Error: $error'))),
        data: (data) {
          return currentUser.when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) =>
                Scaffold(body: Center(child: Text('Error: $error'))),
            data: (user) {
              if (user == null) {
                return const LoginScreen();
              } else {
                return const ChatScreen();
              }
            },
          );
        },
      ),
    );
  }
}
