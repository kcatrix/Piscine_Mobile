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
          // Infos de localisation
      String _city = "";
      String _region = "";
      String _country = "";

      // Météo actuelle
      double _currentTemp = 0.0;
      String _currentWeatherDesc = "";
      double _currentWindSpeed = 0.0;

      // Météo du jour (par heure)
      List<String> _hourlyTimes = [];
      List<double> _hourlyTemps = [];
      List<String> _hourlyWeatherDesc = [];
      List<double> _hourlyWindSpeeds = [];

      // Prévisions sur la semaine
      List<String> _weeklyDates = [];
      List<double> _weeklyTempMin = [];
      List<double> _weeklyTempMax = [];
      List<String> _weeklyWeatherDesc = [];
    
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
      _getWeather(_search);
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
        _searchLocation(formattedCity);
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
            _getWeather(cityName);
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
    void _getWeather(String value) async {
  String city = value.split(",").first;
  final String geoUrl =
      "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1&language=fr&format=json";

  try {
    final geoResponse = await http.get(Uri.parse(geoUrl));

    if (geoResponse.statusCode == 200) {
      final geoData = json.decode(geoResponse.body);

      if (geoData['results'] != null && geoData['results'].isNotEmpty) {
        double latitude = geoData['results'][0]['latitude'];
        double longitude = geoData['results'][0]['longitude'];
        String region = geoData['results'][0]['admin1'] ?? "Région inconnue";
        String country = geoData['results'][0]['country'] ?? "Pays inconnu";

        final String weatherUrl =
            "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&hourly=temperature_2m,weathercode,windspeed_10m&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=Europe/Paris";

        final weatherResponse = await http.get(Uri.parse(weatherUrl));

        if (weatherResponse.statusCode == 200) {
          final weatherData = json.decode(weatherResponse.body);

          setState(() {
            // Infos de localisation
            _city = city;
            _region = region;
            _country = country;

            // Météo actuelle
            _currentTemp = weatherData['current_weather']['temperature'];
            _currentWeatherDesc = _getWeatherDescription(weatherData['current_weather']['weathercode']);
            _currentWindSpeed = weatherData['current_weather']['windspeed'];

            // Météo du jour (par heure)
            _hourlyTimes = List<String>.from(weatherData['hourly']['time']);
            _hourlyTemps = List<double>.from(weatherData['hourly']['temperature_2m']);
            _hourlyWeatherDesc = weatherData['hourly']['weathercode'].map<String>(_getWeatherDescription).toList();
            _hourlyWindSpeeds = List<double>.from(weatherData['hourly']['windspeed_10m']);

            // Prévisions sur la semaine
            _weeklyDates = List<String>.from(weatherData['daily']['time']);
            _weeklyTempMin = List<double>.from(weatherData['daily']['temperature_2m_min']);
            _weeklyTempMax = List<double>.from(weatherData['daily']['temperature_2m_max']);
            _weeklyWeatherDesc = weatherData['daily']['weathercode'].map<String>(_getWeatherDescription).toList();
          });
        } else {
          print("Erreur lors de la récupération de la météo: ${weatherResponse.statusCode}");
        }
      } else {
        print("Aucune donnée géographique trouvée pour $city");
      }
    } else {
      print("Erreur : ${geoResponse.statusCode}");
    }
  } catch (e) {
    print("Erreur lors de la requête : $e");
  }
  setState(() {});
}

// Fonction pour convertir le weathercode en description
String _getWeatherDescription(int code) {
  Map<int, String> weatherDescriptions = {
    0: "Ciel dégagé",
    1: "Principalement dégagé",
    2: "Partiellement nuageux",
    3: "Nuageux",
    45: "Brouillard",
    48: "Brouillard givrant",
    51: "Bruine légère",
    53: "Bruine modérée",
    55: "Bruine dense",
    61: "Pluie légère",
    63: "Pluie modérée",
    65: "Pluie forte",
    80: "Averses légères",
    81: "Averses modérées",
    82: "Averses fortes",
    95: "Orages",
    96: "Orages avec grêle légère",
    99: "Orages avec grêle forte",
  };

  return weatherDescriptions[code] ?? "Météo inconnue";
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
                      _getWeather(_search);
                    } else {
                      _searchLocation("Could not find any result for the supplied address or cordinates");
                      _changeTextStyle(const Color.fromARGB(255, 255, 1, 1));
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
                        if (_search.isNotEmpty && _search != "Geolocation is not available, please enable it in your app settings" && _search != "Could not find any result for the supplied address or cordinates") ...[ 
                        const Text("Currently", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          Text(
                            _search,
                            style: _textStyle,
                          ),
                          Text(
                            "La température actuelle est de $_currentTemp°C",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "Météo : $_currentWeatherDesc", // Ajout de la description météo ici
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "La vitesse du vent est actuellement de $_currentWindSpeed Km/h",
                            style: TextStyle(fontSize: 20),
                          ),
                        ]
                        else
                          Text(_search,
                          style: TextStyle(color: Color.fromARGB(255, 255, 1, 1)))
                      ],
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_search != "Geolocation is not available, please enable it in your app settings") ...[
                        const Text("Today", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                        Text(
                          _search,
                          style: _textStyle,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 24, // On affiche les 24 prochaines heures
                            itemBuilder: (context, index) {
                              // Formatage de l'heure
                              String time = _hourlyTimes.isNotEmpty 
                                ? DateTime.parse(_hourlyTimes[index]).hour.toString().padLeft(2, '0') + 'h'
                                : '';
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: ListTile(
                                  leading: Text(time, 
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                  ),
                                  title: Text('${_hourlyTemps.isNotEmpty ? _hourlyTemps[index].toString() + '°C' : ''}',
                                    style: const TextStyle(fontSize: 16)
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_hourlyWeatherDesc.isNotEmpty ? _hourlyWeatherDesc[index] : ''),
                                      Text(_hourlyWindSpeeds.isNotEmpty 
                                        ? 'Vent: ${_hourlyWindSpeeds[index].toString()} km/h' 
                                        : ''
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else
                        Text(_search,
                        style: TextStyle(color: Color.fromARGB(255, 255, 1, 1))),
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