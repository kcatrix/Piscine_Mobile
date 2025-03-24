import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sample/screen/profile_screen.dart';
import 'services/firestore_service.dart';
import 'constants.dart';
import 'screen/hero_screen.dart';
import 'screen/user_screen.dart';
import 'widgets/add_note_button.dart';
import 'screen/calendar_screen.dart';

class ExampleApp extends StatefulWidget {
  final Auth0? auth0;
  const ExampleApp({this.auth0, final Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  UserProfile? _user;
  late Auth0 auth0;
  late Auth0Web auth0Web;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    auth0 = widget.auth0 ??
        Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    auth0Web =
        Auth0Web(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);

    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) {
        setState(() {
          _user = credentials?.user;
        });
      });
    }
  }

  Future<void> login() async {
    try {
      if (kIsWeb) {
        return auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
      }

      var credentials = await auth0
          .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
          .login(useHTTPS: true);

      setState(() {
        _user = credentials.user;
      });
      await FirestoreService().saveUser(credentials.user);
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    try {
      if (kIsWeb) {
        await auth0Web.logout(returnToUrl: 'http://localhost:3000');
      } else {
        await auth0
            .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
            .logout(useHTTPS: true);
        setState(() {
          _user = null;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(
            top: padding,
            bottom: padding / 6,
            left: padding / 2,
            right: padding / 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _user != null
                        ? Expanded(
                            child: _selectedIndex == 0
                                ? ProfilsWidget(user: _user)
                                : CalendarWidget(user: _user),
                          )
                        : const Expanded(child: HeroWidget()),
                  ],
                ),
              ),
              _user != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: logout,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                          ),
                          child: const Text('Logout'),
                        ),
                        const SizedBox(width: 40),
                        AddNoteButton(
                          nickname: _user?.nickname ?? "Unknown",
                          email: _user?.email ?? "Unknown",
                          onNoteAdded: () {
                            setState(() {});
                          },
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: login,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
        bottomNavigationBar: _user != null
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today),
                    label: 'Calendar',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
