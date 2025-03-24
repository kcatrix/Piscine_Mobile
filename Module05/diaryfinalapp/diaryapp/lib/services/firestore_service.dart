import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 Enregistre l'utilisateur avec son nickname comme identifiant unique
  Future<void> saveUser(UserProfile user) async {
    await _db.collection('users').doc(user.nickname).set({
      'name': user.name,
      'nickname': user.nickname, // Utilisé comme ID unique
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print("✅ Utilisateur enregistré : \${user.name} (\${user.nickname})");
  }

  // 🔹 Enregistre une note en associant le nickname de l'utilisateur
  Future<void> saveNote(String nickname, String title, String description, String feeling) async {
    await _db.collection('notes').add({
      'nickname': nickname, // Stocke le nickname de l'utilisateur
      'Title': title,
      'Description': description,
      'Feeling': feeling,
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("✅ Note enregistrée pour \${nickname}");
  }

  // 🔹 Récupère uniquement les notes d’un utilisateur spécifique
  Future<List<Map<String, dynamic>>> getUserNotes(String userId) async {
    try {
      var snapshot = await _db.collection('notes').where('Nickname', isEqualTo: userId).get();
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // ✅ Ajoute l'ID du document dans les données
        return data;
      }).toList();
    } catch (e) {
      print("❌ Erreur lors de la récupération des notes : $e");
      return [];
    }
  }

    Stream<List<Map<String, dynamic>>> getUserNotesStream(String userId) {
    return FirebaseFirestore.instance
        .collection('notes')
        .where('Nickname', isEqualTo: userId) // Filtrer par utilisateur
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Ajouter l'ID Firestore à chaque note
            return data;
          }).toList();
        });
  }

  // 🔹 Supprime une note par son ID
  Future<void> deleteNote(String noteId) async {
    try {
      await _db.collection('notes').doc(noteId).delete();
      print("🗑 Note supprimée : \$noteId");
    } catch (e) {
      print("❌ Erreur lors de la suppression de la note : \$e");
    }
  }
}
