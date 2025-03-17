import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

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
  
  // Ajout des variables pour les suggestions
  List<Map<String, String>> _citySuggestions = [];
  bool _isShowingSuggestions = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pas besoin d'ajouter un listener complet, nous utiliserons onChanged
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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

  // Méthode pour obtenir les suggestions de villes
  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _citySuggestions = [];
        _isShowingSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await searchCities(query);
      setState(() {
        _citySuggestions = suggestions;
        _isShowingSuggestions = suggestions.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur lors de la recherche de suggestions: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour sélectionner une ville dans les suggestions
  void _selectCity(Map<String, String> city) {
    // Formater le nom de la ville avec sa région et son pays
    String formattedCity = "${city['name']}";
    if (city['region'] != "Région inconnue") {
      formattedCity += ", ${city['region']}";
    }
    if (city['country'] != "Pays inconnu") {
      formattedCity += ", ${city['country']}";
    }
    
    setState(() {
      _search = formattedCity;
      _isShowingSuggestions = false;
      _searchController.clear();
      _changeTextStyle(Colors.black);
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

  Future<List<Map<String, String>>> searchCities(String query) async {
    if (query.isEmpty) return [];

    final String url =
        "https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=fr&format=json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'] is List) {
          return (data['results'] as List)
              .map((city) => {
                    "name": city['name'] as String? ?? "Nom inconnu",
                    "region": city['admin1'] as String? ?? "Région inconnue",
                    "country": city['country'] as String? ?? "Pays inconnu",
                  })
              .toList();
        }
      } else {
        print("Erreur : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la requête : $e");
    }

    return [];
  }

  Future<String?> getCityName(double latitude, double longitude) async {
    final String url =
        "https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['address']['city'] ?? data['address']['town'] ?? data['address']['village'] ?? "Ville inconnue";
      } else {
        print("Erreur : ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la requête : $e");
      return null;
    }
  }

  Future<void> _geolocation() async {
    try {
      setState(() {
        _search = "Recherche de votre position...";
        _isShowingSuggestions = false;
      });
      
      LocationData position = await _determinePosition();
      String? cityName = await getCityName(position.latitude!, position.longitude!);
      if (cityName != null) {
        final citySuggestions = await searchCities(cityName);
        if (citySuggestions.isNotEmpty) {
          final city = citySuggestions.first;
          cityName = "${city['name']}, ${city['region']}, ${city['country']}";
        }
      }
      setState(() {
        _search = cityName ?? "Ville inconnue";
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
      _isShowingSuggestions = false; // Fermer les suggestions lors du changement d'onglet
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
                onChanged: (value) {
                  if (value.length >= 2) {
                    _getSuggestions(value);
                  } else {
                    setState(() {
                      _citySuggestions = [];
                      _isShowingSuggestions = false;
                    });
                  }
                },
                onSubmitted: (value) async {
                  if (_citySuggestions.isNotEmpty) {
                    _selectCity(_citySuggestions.first);
                  } else {
                    _searchLocation("Ville inconnu");
                    _changeTextStyle(Colors.black);
                    _searchController.clear();
                    setState(() {
                      _isShowingSuggestions = false;
                    });
                  }
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
      body: Stack(
        children: [
          // PageView principal
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
                _isShowingSuggestions = false; // Fermer les suggestions lors du changement de page
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
          
          // Suggestions (apparaissent au-dessus du contenu principal)
          if (_isShowingSuggestions)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: Card(
                  elevation: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: _isLoading
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _citySuggestions.length,
                          itemBuilder: (context, index) {
                            final city = _citySuggestions[index];
                            return ListTile(
                              title: Text(city['name'] ?? ""),
                              subtitle: Text(
                                "${city['region'] != 'Région inconnue' ? city['region'] : ''}, ${city['country'] ?? ''}"
                                    .replaceAll(RegExp(r'^, '), ''),
                              ),
                              onTap: () => _selectCity(city),
                            );
                          },
                        ),
                ),
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