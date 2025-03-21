import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(UserProfile user) async {
    await _db.collection('notes').doc(user.sub).set({
      'name': user.name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(), // Ajout de la date
    });

    print("✅ Utilisateur enregistré dans Firestore : ${user.name}, ${user.email}, DateTime.now()}");
  }
}
