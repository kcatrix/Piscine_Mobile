import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../widgets/note_card.dart';

class ProfilsWidget extends StatelessWidget {
  final UserProfile? user;
  final FirestoreService _firestoreService = FirestoreService();

  ProfilsWidget({required this.user, Key? key}) : super(key: key);

  String getFeelingEmoji(String feeling) {
    switch (feeling) {
      case "happy":
        return "😊";
      case "sad":
        return "😢";
      case "angry":
        return "😠";
      case "neutral":
        return "😐";
      case "excited":
        return "🤩";
      default:
        return "📝";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || user!.nickname == null) {
      return const Center(child: Text("Utilisateur non connecté"));
    }

    String userId = user!.nickname!;
    String profileImageUrl = (user!.pictureUrl ?? 'https://example.com/default-profile-image.png').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            SizedBox(width: 16),
            Text(
              user!.nickname!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            "Your last diary entries",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
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
        Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notes')
                .where('Nickname', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Aucun"));
              }
              var docs = snapshot.data!.docs;
              int totalNotes = docs.length;
              Map<String, int> feelingCounts = {};

              for (var doc in docs) {
                String feeling = doc['Feeling'] ?? 'unknown';
                feelingCounts[feeling] = (feelingCounts[feeling] ?? 0) + 1;
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8),
                  Text(
                    "Nombre total de notes : $totalNotes",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...feelingCounts.entries.map((entry) {
                    double percentage = (entry.value / totalNotes) * 100;
                    return Text(
                      "${getFeelingEmoji(entry.key)} ${entry.key.capitalize()} : ${entry.value} fois (${percentage.toStringAsFixed(1)}%)",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
  }
}