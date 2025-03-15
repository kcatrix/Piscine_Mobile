import 'package:flutter/material.dart';
import 'package:location/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Geolocation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Geolocation Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _search = "";
  TextStyle _textStyle = TextStyle(color: const Color.fromARGB(255, 0, 0, 0));
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  final Location location = Location();

  void _searchLocation(String search) {
    setState(() {
      _search = search;
    });
  }

  void _changeTextStyle(couleur) {
    setState(() {
      _textStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: couleur,
      );
    });
  }

  Future<LocationData> _determinePosition() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Vérifier si le service est activé
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    // Vérifier les permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.error('Location permissions are denied');
      }
    }

    // Obtenir la position
    return await location.getLocation();
  }

  Future<void> _geolocation() async {
    try {
      setState(() {
        _search = "Recherche de votre position...";
      });
      
      LocationData position = await _determinePosition();
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_search != "Geolocation is not available, please enable it in your app settings")
                  const Text("Currently", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(
                  _search,
                  style: _textStyle,
                )
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_search != "Geolocation is not available, please enable it in your app settings")
                  const Text("Today", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(
                  _search,
                  style: _textStyle,
                )
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_search != "Geolocation is not available, please enable it in your app settings")
                  const Text("Weekly", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(
                  _search,
                  style: _textStyle,
                )
              ],
            ),
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
              icon: Icon(Icons.calendar_month),
              label: 'Weekly',
            ),
          ],
        ),
      ),
    );
  }
}