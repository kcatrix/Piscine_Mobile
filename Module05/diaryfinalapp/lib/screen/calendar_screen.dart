import 'package:flutter/material.dart';
import '../widgets/calendar.dart';

class CalendarScreenWidget extends StatefulWidget {
  const CalendarScreenWidget({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Pour éviter que le calendrier touche la barre du haut
        child: SingleChildScrollView( // Permet de scroller si besoin
          child: Column(
            children: [
              /// Le calendrier prend la hauteur qu'il veut sans overflow
              CalendarWidget(),

              /// Espace pour séparer le texte
              SizedBox(height: 20),

              /// Partie texte en bas
              Text("data"),
              Text("data"),
            ],
          ),
        ),
      ),
    );
  }
}
