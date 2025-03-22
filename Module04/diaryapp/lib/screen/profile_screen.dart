import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
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

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _firestoreService.getUserNotes(userId),
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
            var noteData = snapshot.data![index];
            return NoteCard(
              noteId: noteData['id'] ?? '', // Assure-toi que Firestore retourne un ID
              note: noteData,
            );
          },
        );
      },
    );
  }
}