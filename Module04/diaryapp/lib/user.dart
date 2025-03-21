import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class UserWidget extends StatelessWidget {
  final UserProfile? user;

  const UserWidget({required this.user, final Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? pictureUrl = user?.pictureUrl?.toString();
    final provider = user?.sub?.split('|').first ?? '';
    final username = user?.sub?.split('|').last ?? '';

    String displayValue = '';
    String getUsername(UserProfile user) {
      if (user.nickname != null) {
        return user.nickname!;
      } else if (user.name != null) {
        return user.name!;
      } else {
        return 'Utilisateur inconnu';
      }
    }
    if (provider == 'google-oauth2') {
      displayValue = user?.email ?? 'Email inconnu';
    } else if (provider == 'github') {
      displayValue = getUsername(user!);
    } else {
      displayValue = 'Utilisateur inconnu';
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'), // Assure-toi d'ajouter l'image dans assets
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pictureUrl != null)
                CircleAvatar(
                  radius: 56,
                  backgroundImage: NetworkImage(pictureUrl),
                ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white.withOpacity(0.8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _userInfoRow('Connecté avec ', provider.toUpperCase()),
                      _userInfoRow(provider == 'google-oauth2' ? 'Email' : 'Username', displayValue),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
