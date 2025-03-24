import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNoteButton extends StatefulWidget {
  final Function() onNoteAdded;
  final String nickname;
  final String email;

  const AddNoteButton({Key? key, required this.onNoteAdded, required this.nickname, required this.email}) : super(key: key);

  @override
  _AddNoteButtonState createState() => _AddNoteButtonState();
}

class _AddNoteButtonState extends State<AddNoteButton> {
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
          content: StatefulBuilder( // Utilisation de StatefulBuilder pour rafraîchir uniquement l'UI du dialogue
            builder: (context, setState) {
              return Column(
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
                            setState(() { // On utilise le setState local ici
                              selectedFeeling = value;
                            });
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
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty) return;

                await FirebaseFirestore.instance.collection('notes').add({
                  'Title': titleController.text,
                  'Description': descriptionController.text,
                  'Feeling': selectedFeeling,
                  'createdAt': Timestamp.now(),
                  'Nickname': widget.nickname,
                  'Email' : widget.email,
                });

                widget.onNoteAdded();
                Navigator.pop(context);
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
