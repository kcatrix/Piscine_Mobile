import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth0',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Credentials? _credentials;
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(
      'dev-vekudtrpuzp0gs3i.eu.auth0.com', 
      '1DMEXYmuKMNUkAJM3LvaEygbpFVGNBBw'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _credentials == null
            ? ElevatedButton(
                onPressed: () async {
                  try {
                    final credentials = await auth0.webAuthentication().login(
                      useHTTPS: true,
                      redirectUrl: "https://dev-vekudtrpuzp0gs3i.eu.auth0.com/android/com.example.diaryapp/callback",
                    );
                    setState(() {
                      _credentials = credentials;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur de connexion: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Se connecter"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Bienvenue, ${_credentials?.user.name ?? 'Utilisateur'}"),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await auth0.webAuthentication().logout(
                          useHTTPS: true,
                          returnTo: "https://dev-vekudtrpuzp0gs3i.eu.auth0.com/android/com.example.diaryapp/callback",
                        );
                        setState(() {
                          _credentials = null;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur de déconnexion: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text("Se déconnecter"),
                  ),
                ],
              ),
      ),
    );
  }
}
