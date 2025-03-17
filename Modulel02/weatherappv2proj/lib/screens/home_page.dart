import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../widgets/weather_page.dart';
import 'package:location/location.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _search = "";
  TextStyle _textStyle = const TextStyle(color: Color.fromARGB(255, 0, 0, 0));
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  final LocationService _locationService = LocationService();

  void _searchLocation(String search) {
    setState(() {
      _search = search;
    });
  }

  void _changeTextStyle(Color couleur) {
    setState(() {
      _textStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: couleur,
      );
    });
  }

  Future<void> _geolocation() async {
    try {
      setState(() {
        _search = "Recherche de votre position...";
      });
      
      LocationData position = await _locationService.determinePosition();
      setState(() {
        _search = "Lat: ${position.latitude}, Lng: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        _search = "Geolocation is not available, please enable it in your app settings";
        _changeTextStyle(Colors.red);
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  _searchLocation(value);
                  _changeTextStyle(Colors.black);
                  _searchController.clear();
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search location ...",
                  border: InputBorder.none, 
                ),
              ),
            ),
            const Text("|", style: TextStyle(fontSize: 20, color: Colors.white)),
            IconButton(
              onPressed: _geolocation,
              icon: const Icon(Icons.location_on),
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
          WeatherPage(
            title: "Currently",
            search: _search,
            textStyle: _textStyle,
          ),
          WeatherPage(
            title: "Today",
            search: _search,
            textStyle: _textStyle,
          ),
          WeatherPage(
            title: "Weekly",
            search: _search,
            textStyle: _textStyle,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(255, 2, 88, 247),
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny),
              label: 'Currently',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.today),
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_week),
              label: 'Weekly',
            ),
          ],
        ),
      ),
    );
  }
}
