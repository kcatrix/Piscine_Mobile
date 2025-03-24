import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class NoteCard extends StatefulWidget {
  final String noteId;
  final Map<String, dynamic> note;

  const NoteCard({Key? key, required this.noteId, required this.note}) : super(key: key);

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  final FirestoreService _firestoreService = FirestoreService();

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
        return "📝";
    }
  }

  // Fonction pour supprimer une note
  Future<void> _deleteNote(BuildContext context) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this entry?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _firestoreService.deleteNote(widget.noteId);
      if (mounted) {
        setState(() {}); // Rafraîchir l'affichage après suppression
      }
      Navigator.pop(context);
    }
  }

  // Fonction pour afficher le popup avec les détails de la note
  void _showNoteDetails(BuildContext context) {
    String formattedDate = "Date inconnue";
    if (widget.note['createdAt'] is Timestamp) {
      DateTime date = (widget.note['createdAt'] as Timestamp).toDate();
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
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("My feeling : ", style: TextStyle(fontSize: 18)),
                  Text(getEmoji(widget.note['Feeling']), style: const TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.note['Description'] ?? "Aucune description",
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _deleteNote(context),
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
    String formattedDate = "Date inconnue";
    if (widget.note['createdAt'] is Timestamp) {
      DateTime date = (widget.note['createdAt'] as Timestamp).toDate();
      formattedDate = DateFormat('d MMM yyyy').format(date);
    }

   return GestureDetector(
  onTap: () => _showNoteDetails(context),
  child: Card(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.green.shade400, width: 2),
    ),
    child: Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05, // Décalage dynamique (~5% de la largeur)
        right: 12,
        top: 8,
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                formattedDate.split(" ")[0],
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.045, // Taille adaptable
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formattedDate.split(" ")[1],
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                getEmoji(widget.note['Feeling']),
                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06),
              ),
            ],
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03), // Espacement dynamique
          Container(height: 50, width: 2, color: Colors.grey.shade400),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: Center(
                child: Text(
                  widget.note['Title'] ?? "Sans titre",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06, // Réduction de la taille du texte
                    fontWeight: FontWeight.w600,
                  ),
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