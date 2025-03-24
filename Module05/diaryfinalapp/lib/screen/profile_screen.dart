import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../widgets/note_card.dart';

class ProfilsWidget extends StatelessWidget {
  final UserProfile? user;
  final FirestoreService _firestoreService = FirestoreService();

  ProfilsWidget({required this.user, Key? key}) : super(key: key);

  // 🔥 Associer un emoji à chaque feeling
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
        return "📝"; // Par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || user!.nickname == null) {
      return const Center(child: Text("Utilisateur non connecté"));
    }

    String userId = user!.nickname!; // Utilisation du nickname comme ID utilisateur
    String profileImageUrl = (user!.pictureUrl ?? 'https://example.com/default-profile-image.png').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alignement du contenu à gauche
      children: [
        // 🔹 Affichage de l'image de profil et du nickname
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(profileImageUrl), // Image de profil
              ),
              const SizedBox(width: 16),
              Text(
                user!.nickname!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Text(
            "Your last diary entries",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // 🔹 Affichage des 2 dernières notes de l'utilisateur
        Container(
          height: MediaQuery.of(context).size.height * 0.3, // Limiter la taille
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notes')
                .where('Nickname', isEqualTo: userId) // Filtrer uniquement les notes de l'utilisateur
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
        // 🔹 Affichage des stats des feelings avec émojis et pourcentage (filtrés par utilisateur)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity, // Prendre toute la largeur disponible
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notes')
                      .where('Nickname', isEqualTo: userId) // Filtrer les notes de l'utilisateur
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Aucun feeling"));
                    }

                    var docs = snapshot.data!.docs;
                    int totalNotes = docs.length;
                    Map<String, int> feelingCounts = {};

                    // 🔹 Compter les occurrences des feelings pour l'utilisateur
                    for (var doc in docs) {
                      String feeling = doc['Feeling'] ?? 'unknown';
                      feelingCounts[feeling] = (feelingCounts[feeling] ?? 0) + 1;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
                      children: [
                        Text(
                          "Total de notes pour $userId : $totalNotes",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        // Affichage des feelings
                        ...feelingCounts.entries.map((entry) {
                          // Calculer le pourcentage
                          double percentage = (entry.value / totalNotes) * 100;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9), // Limiter la largeur des items
                              child: Text(
                                "${getFeelingEmoji(entry.key)} ${entry.key.capitalize()} : ${entry.value} fois (${percentage.toStringAsFixed(1)}%)",
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis, // Éviter le débordement de texte
                                maxLines: 1, // Limiter à une ligne pour éviter l'overflow
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ],
            ),
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
