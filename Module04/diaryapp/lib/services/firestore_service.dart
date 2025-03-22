import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 Enregistre l'utilisateur avec une date
  Future<void> saveUser(UserProfile user) async {
    await _db.collection('notes').doc(user.sub).set({
      'name': user.name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print("✅ Utilisateur enregistré : ${user.name}, ${user.email}");
  }

  // 🔹 Enregistre une note avec une date
  Future<void> saveNote(UserProfile user, notes) async {
    await _db.collection('notes').doc(user.sub).set({
      'name': user.name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'Feeling': notes.Feeling,
      'Title': notes.title,
      'Description': notes.description,
    }, SetOptions(merge: true));

    print("✅ Note enregistrée pour ${user.name}");
  }

  // 🔹 Récupère toutes les notes en s'assurant que la date existe
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      var snapshot = await _db.collection('notes').get();
      List<Map<String, dynamic>> notes = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();

        if (data['createdAt'] == null) {
          // 🔥 Ajoute une date si absente et attend la mise à jour
          await _db.collection('notes').doc(doc.id).update({
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 🔄 Re-fetch les données après la mise à jour
          var updatedDoc = await _db.collection('notes').doc(doc.id).get();
          data = updatedDoc.data()!;
          print("🕒 Date ajoutée pour la note ${doc.id}");
        }

        notes.add(data);
      }

      return notes;
    } catch (e) {
      print("❌ Erreur lors de la récupération des notes : $e");
      return [];
    }
  }
}
