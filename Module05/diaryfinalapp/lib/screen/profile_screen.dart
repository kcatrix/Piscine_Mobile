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

    String userId = user!.nickname!; // Utilisation du nickname comme ID utilisateur

    return Column(
      children: [
        // 🔹 Affichage des 2 dernières notes de l'utilisateur
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notes')
                .where('Nickname', isEqualTo: userId)
                .orderBy('createdAt', descending: true)
                .limit(2)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Aucune note"));
              }

              var notes = snapshot.data!.docs.map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
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
          ),
        ),

        // 🔹 Affichage des stats des feelings
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('notes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData) return const Text("Aucune note");

            var docs = snapshot.data!.docs;
            int totalNotes = docs.length;
            Map<String, int> feelingCounts = {};

            for (var doc in docs) {
              String feeling = doc['Feeling'] ?? 'unknown';
              feelingCounts[feeling] = (feelingCounts[feeling] ?? 0) + 1;
            }

            return Column(
              children: [
                Text("Total de notes : $totalNotes"),
                ...feelingCounts.entries.map((entry) => Text("feeling '${entry.key}': ${entry.value} fois")),
              ],
            );
          },
        ),
      ],
    );
  }
}
