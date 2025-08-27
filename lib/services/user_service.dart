// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../providers/firebase_providers.dart'; // আমাদের自定义 মডেল import করুন

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserService(this._firestore, this._auth);

  // সব users পান (chat শুরু করার জন্য)
  Stream<List<AppUser>> getUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppUser.fromFirebase(doc.data()))
        .toList());
  }

  // Current user information সেভ করুন
  Future<void> saveUser(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    });
  }

  // User information পান
  Future<AppUser?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return AppUser.fromFirebase(doc.data()!);
    }
    return null;
  }
}