import 'package:flutter/material.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService authService = AuthService();
  String? userName;

  Future<void> _login() async {
    final user = await authService.login();
    if (user != null) {
      setState(() {
        userName = user.name;
      });
    }
  }

  Future<void> _logout() async {
    await authService.logout();
    setState(() {
      userName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auth0 Login")),
      body: Center(
        child: userName == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text("Se connecter avec Auth0"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Bienvenue, $userName"),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text("Se déconnecter"),
                  ),
                ],
              ),
      ),
    );
  }
}
