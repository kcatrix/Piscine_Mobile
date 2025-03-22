import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'services/firestore_service.dart';

class ProfilsWidget extends StatelessWidget {
  final UserProfile? user;
  final FirestoreService _firestoreService = FirestoreService();

  ProfilsWidget({required this.user, Key? key}) : super(key: key);

  
  // Fonction pour récupérer l'emoji selon le sentiment (Feeling)
  String getEmoji(String? feeling) {
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
        return "📝"; // Icône par défaut
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _firestoreService.getAllNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune note"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var note = snapshot.data![index];

            // ✅ Formatage de la date
            String formattedDate = "Date inconnue";
            if (note['createdAt'] is Timestamp) {
              DateTime date = (note['createdAt'] as Timestamp).toDate();
              formattedDate = DateFormat('d MMM yyyy').format(date);
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Coins arrondis
                side: BorderSide(color: Colors.green.shade400, width: 2), // Bordure verte
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 📅 Date et emoji
                    Column(
                      children: [
                        Text(
                          formattedDate.split(" ")[0], // Jour
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formattedDate.split(" ")[1], // Mois
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          getEmoji(note['Feeling']),
                          style: const TextStyle(fontSize: 20), // Emoji
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // 📌 Titre et description
                    Expanded(
                      child: Center(
                      child: Text(
                        note['Title'] ?? "Sans titre",
                        style: const TextStyle(
                        fontSize: 35, 
                        fontWeight: FontWeight.w600,
                        ),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
