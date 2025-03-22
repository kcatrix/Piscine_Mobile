import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteCard extends StatelessWidget {
  final Map<String, dynamic> note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  // Fonction pour récupérer l'emoji selon le sentiment
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

  // Fonction pour afficher le popup avec les détails de la note
  void _showNoteDetails(BuildContext context) {
    // ✅ Formatage de la date
    String formattedDate = "Date inconnue";
    if (note['createdAt'] is Timestamp) {
      DateTime date = (note['createdAt'] as Timestamp).toDate();
      formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📅 Date en titre
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 😊 Sentiment
              Row(
                children: [
                  const Text("My feeling : ", style: TextStyle(fontSize: 18)),
                  Text(getEmoji(note['Feeling']), style: const TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 10),

              // 📝 Description de la note
              Text(
                note['Description'] ?? "Aucune description",
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),

              // ❌ Bouton de suppression
              GestureDetector(
                onTap: () {
                  // Requete suppresion db
                  Navigator.pop(context); // Ferme le popup
                },
                child: const Text(
                  "🗑 Delete this entry",
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Formatage de la date
    String formattedDate = "Date inconnue";
    if (note['createdAt'] is Timestamp) {
      DateTime date = (note['createdAt'] as Timestamp).toDate();
      formattedDate = DateFormat('d MMM yyyy').format(date);
    }

    return GestureDetector(
      onTap: () => _showNoteDetails(context), // 📌 Rend la carte cliquable
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.green.shade400, width: 2),
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formattedDate.split(" ")[1], // Mois
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 5),
                  Text(getEmoji(note['Feeling']), style: const TextStyle(fontSize: 20)),
                ],
              ),

              // 🔹 Barre de séparation verticale
              const SizedBox(width: 12),
              Container(
                height: 50,
                width: 2,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 12),

              // 📌 Titre et description
              Expanded(
                child: Center(
                  child: Text(
                    note['Title'] ?? "Sans titre",
                    style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
