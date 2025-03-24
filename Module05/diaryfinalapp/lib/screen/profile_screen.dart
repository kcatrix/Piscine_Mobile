import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../widgets/note_card.dart';

class ProfilsWidget extends StatelessWidget {
  final UserProfile? user;
  final FirestoreService _firestoreService = FirestoreService();

  ProfilsWidget({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null || user!.nickname == null) {
      return const Center(child: Text("Utilisateur non connecté"));
    }

    String userId = user!.nickname!; // 🔥 Utilisation du nickname comme ID utilisateur

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .where('Nickname', isEqualTo: userId)// Filtrer par utilisateur
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Aucune note"));
        }
        var notes = snapshot.data!.docs.map((doc) => {
          'id': doc.id, // Récupérer l'ID Firestore
          ...doc.data() as Map<String, dynamic>, // Récupérer les données de la note
        }).toList();

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            var noteData = notes[index];
            return NoteCard(
              noteId: noteData['id'] ?? '',
              note: noteData,
            );
          },
        );
      },
    );
  }
}
