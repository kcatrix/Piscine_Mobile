import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/calendar.dart';

class CalendarScreenWidget extends StatefulWidget {
  const CalendarScreenWidget({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreenWidget> {
  DateTime _selectedDay = DateTime.now(); // Garde la date sélectionnée

  void _onDateSelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
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
                            .where('Nickname', isEqualTo: "userId") // Remplace avec la vraie variable userId
                            .where('createdAt',
                                isGreaterThanOrEqualTo: Timestamp.fromDate(
                                  DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day),
                                ),
                                isLessThan: Timestamp.fromDate(
                                  DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day + 1),
                                ))
                            .orderBy('createdAt', descending: true)
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
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(note['title'] ?? 'Sans titre'),
                                  subtitle: Text(note['content'] ?? 'Pas de contenu'),
                                  trailing: Text(
                                    note['createdAt'] != null
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                                note['createdAt'].millisecondsSinceEpoch)
                                            .toLocal()
                                            .toString()
                                        : '',
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
