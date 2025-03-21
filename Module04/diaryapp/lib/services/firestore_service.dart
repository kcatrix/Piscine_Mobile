import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(UserProfile user) async {
    await _db.collection('users').doc(user.sub).set({
      'name': user.name,
      'email': user.email,
    });

    print("✅ Utilisateur enregistré dans Firestore : ${user.name}, ${user.email}");
  }
}
