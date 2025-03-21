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

    print("✅ Utilisateur enregistré dans Firestore : ${user.name}, ${user.email}, ${DateTime.now()}");
  }

  Future<void> saveNote(UserProfile user, notes) async{
    await _db.collection('notes').doc(user.sub).set({
      'name': user.name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(), // Ajout de la date
      'Felling' : notes.Feeling,
      'Title' : notes.title,
      'Description' : notes.description
    });
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
  try {
    QuerySnapshot querySnapshot = await _db.collection('notes').get();
    
    List<Map<String, dynamic>> notes = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();

    return notes;
    }
    catch (e) {
    print("❌ Erreur lors de la récupération des notes : $e");
    return [];
    }
  }
}
