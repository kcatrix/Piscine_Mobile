import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNoteButton extends StatelessWidget {
  final Function() onNoteAdded;
  final String nickname; // Récupère le nickname de l'utilisateur connecté

  const AddNoteButton({Key? key, required this.onNoteAdded, required this.nickname}) : super(key: key);

  void _showAddNoteDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String selectedFeeling = "happy"; // Valeur par défaut

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Add an entry", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 📝 Titre de la note
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 10),

              // 😊 Sélection du sentiment
              Row(
                children: [
                  const Text("Feeling: "),
                  DropdownButton<String>(
                    value: selectedFeeling,
                    items: ["happy", "sad", "angry", "neutral", "excited"].map((feeling) {
                      return DropdownMenuItem(value: feeling, child: Text(feeling));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedFeeling = value;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ✏️ Description
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Text"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Fermer la boîte de dialogue
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty) return;

                // Ajouter la note à Firestore avec le nickname de l'utilisateur connecté
                await FirebaseFirestore.instance.collection('notes').add({
                  'Title': titleController.text,
                  'Description': descriptionController.text,
                  'Feeling': selectedFeeling,
                  'createdAt': Timestamp.now(),
                  'Nickname': nickname, // Ajoute le nickname dans Firestore
                });

                onNoteAdded(); // Mettre à jour la liste des notes
                Navigator.pop(context); // Fermer la boîte de dialogue
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddNoteDialog(context),
      backgroundColor: Colors.green,
      child: const Icon(Icons.add, size: 30, color: Colors.white),
    );
  }
}
