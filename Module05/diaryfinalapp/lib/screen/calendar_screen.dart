import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../widgets/note_card.dart';

class CalendarWidget extends StatelessWidget {
  final UserProfile? user;
  final FirestoreService _firestoreService = FirestoreService();

  CalendarWidget({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null || user!.nickname == null) {
      return const Center(child: Text("Utilisateur non connecté"));
    }

    String userId = user!.nickname!;

    return Column(
      children: [
        Text("calendar"),
        // Section des dernières notes
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

        // Section des statistiques
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .where('Nickname', isEqualTo: userId) // Filtrer par utilisateur
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData) {
              return const Text("Aucune note");
            }

            var docs = snapshot.data!.docs;
            int totalNotes = docs.length;
            Map<String, int> feelingCounts = {};

            for (var doc in docs) {
              String feeling = doc['Feeling'] ?? 'unknown';
              feelingCounts[feeling] = (feelingCounts[feeling] ?? 0) + 1;
            }

            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total de notes : $totalNotes",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...feelingCounts.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "Feeling '${entry.key}': ${entry.value} fois",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
