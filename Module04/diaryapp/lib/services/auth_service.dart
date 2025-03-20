import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService {
  final Auth0 auth0 = Auth0(
    'dev-vekudtrpuzp0gs3i.eu.auth0.com', // Ton domaine Auth0
    '1DMEXYmuKMNUkAJM3LvaEygbpFVGNBBw'   // Ton client ID
  );

  Credentials? _credentials;

  Future<UserProfile?> login() async {
    try {
      _credentials = await auth0.webAuthentication(scheme: 'https').login(
        parameters: {
          'redirect_uri': 'https://dev-vekudtrpuzp0gs3i.eu.auth0.com/android/com.example.diaryapp/callback'
        }
      );
      return _credentials?.user;
    } catch (e) {
      print('Erreur de connexion : $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await auth0.webAuthentication().logout();
      _credentials = null;
    } catch (e) {
      print('Erreur de déconnexion : $e');
    }
  }

  bool isAuthenticated() {
    return _credentials != null;
  }
}
