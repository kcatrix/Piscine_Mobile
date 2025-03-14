import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _textController = TextEditingController();

  // ValueNotifier pour mettre à jour le texte en temps réel
  final ValueNotifier<String> _displayedText = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 109, 106, 106),
        title: Row(
          children: [
            const Icon(Icons.search, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Search Localisations ...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (newText) {
                },
                onSubmitted: (value) {
                _displayedText.value = value; // Mettre à jour le texte seulement après "Entrée"
                _textController.clear(); // Vide la barre de texte
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.near_me, color: Colors.white),
              onPressed: () {
                _displayedText.value = "Geolocation"; // Affichage "Geolocation"
              },
            ),
          ],
        ),
      ),

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          CurrentlyPage(displayedTextNotifier: _displayedText),
          TodayPage(displayedTextNotifier: _displayedText),
          WeeklyPage(displayedTextNotifier: _displayedText),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(0, Icons.wb_sunny, "Currently"),
            _buildTabItem(1, Icons.today, "Today"),
            _buildTabItem(2, Icons.calendar_month, "Weekly"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.jumpToPage(index);
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 4), // Small gap between icon and text
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentlyPage extends StatelessWidget {
  final ValueNotifier<String> displayedTextNotifier;
  const CurrentlyPage({super.key, required this.displayedTextNotifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Currently", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: displayedTextNotifier,
            builder: (context, value, child) {
              return Text(value, style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)));
            },
          ),
        ],
      ),
    );
  }
}

class TodayPage extends StatelessWidget {
  final ValueNotifier<String> displayedTextNotifier;
  const TodayPage({super.key, required this.displayedTextNotifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Today", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: displayedTextNotifier,
            builder: (context, value, child) {
              return Text(value, style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)));
            },
          ),
        ],
      ),
    );
  }
}

class WeeklyPage extends StatelessWidget {
  final ValueNotifier<String> displayedTextNotifier;
  const WeeklyPage({super.key, required this.displayedTextNotifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Weekly", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: displayedTextNotifier,
            builder: (context, value, child) {
              return Text(value, style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)));
            },
          ),
        ],
      ),
    );
  }
}
