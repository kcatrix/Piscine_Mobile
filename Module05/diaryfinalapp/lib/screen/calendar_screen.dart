import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:auth0_flutter/auth0_flutter.dart';


class CalendarScreenWidget extends StatefulWidget {
  final UserProfile? user;
  CalendarScreenWidget({required this.user, Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreenWidget> {
  DateTime _selectedDay = DateTime.now(); // Garde la date sélectionnée
  DateTime _focusedDay = DateTime.now(); // Garde le jour focalisé (utilisé pour le mode semaine/mois)
  CalendarFormat _calendarFormat = CalendarFormat.month; // Format du calendrier (mois, semaine...)

  // Calculer la plage de dates en fonction du mode sélectionné (jour, semaine, mois)
  DateTime _getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day); // 00:00:00
  }

  DateTime _getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59); // 23:59:59
  }

  void _onDateSelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
  }

  // Fonction pour récupérer la plage de dates pour la semaine (si en mode semaine)
  DateTime _getStartOfWeek(DateTime date) {
    int difference = date.weekday - DateTime.monday; // Calcul du premier jour de la semaine
    return date.subtract(Duration(days: difference));
  }

  DateTime _getEndOfWeek(DateTime date) {
    int difference = DateTime.sunday - date.weekday; // Calcul du dernier jour de la semaine
    return date.add(Duration(days: difference));
  }

  // Fonction pour récupérer la plage de dates pour le mois (si en mode mois)
  DateTime _getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1); // Premier jour du mois
  }

  DateTime _getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59); // Dernier jour du mois
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// 📅 Partie calendrier
            Container(
              color: Colors.blue.shade50,
              child: CalendarWidget(onDateSelected: _onDateSelected),
            ),

            /// 📝 Partie notes avec liste scrollable
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notes du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),

                    /// 📜 Liste des notes
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notes')
                            // .where('Nickname', isEqualTo: "userId") // Remplace par la vraie variable userId
                            // .where('createdAt',
                            //     isGreaterThanOrEqualTo: Timestamp.fromDate(
                            //       _calendarFormat == CalendarFormat.month
                            //           ? _getStartOfMonth(_selectedDay)
                            //           : (_calendarFormat == CalendarFormat.week
                            //               ? _getStartOfWeek(_selectedDay)
                            //               : _getStartOfDay(_selectedDay)),
                            //     ),
                            //     isLessThan: Timestamp.fromDate(
                            //       _calendarFormat == CalendarFormat.month
                            //           ? _getEndOfMonth(_selectedDay)
                            //           : (_calendarFormat == CalendarFormat.week
                            //               ? _getEndOfWeek(_selectedDay)
                            //               : _getEndOfDay(_selectedDay)),
                            //     ))
                            // .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("Aucune note pour cette date"));
                          }

                          var notes = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              var note = notes[index].data() as Map<String, dynamic>;

                              // Conversion de la date "createdAt" de Timestamp à DateTime
                              String formattedDate = '';
                              if (note['createdAt'] is Timestamp) {
                                DateTime date = (note['createdAt'] as Timestamp).toDate();
                                formattedDate = DateFormat('d MMM yyyy').format(date); // Format sans l'heure
                              }
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(note['title'] ?? 'Sans titre'),
                                  subtitle: Text(note['content'] ?? 'Pas de contenu'),
                                  trailing: Text(
                                    formattedDate, // Affichage de la date formatée
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}