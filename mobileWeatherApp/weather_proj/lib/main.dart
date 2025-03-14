import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedIndex = 0;
  var _search = "";
  var _searchController = TextEditingController();
  final PageController _pageController = PageController();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  void _searchLocation(String search) {
    setState(() {
      _search = search;
    });
  }

  void _geolocation() {
    setState(() {
      _search = "Geolocation";
    });
  }

    void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Change de page instantanément
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == _selectedIndex;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _onItemTapped(index), // Change de page
            icon: Icon(icon, color: isSelected ? Colors.blue : Colors.black), // Change la couleur si actif
          ),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.black, // Texte coloré si actif
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ), 
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller : _searchController,
                onSubmitted: (potatos){
                    _searchLocation(potatos);
                    _searchController.clear();
                  },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search location ...",
                  border: InputBorder.none, 
                ),
              ),
            ),
            Text("|", style: TextStyle(fontSize: 20, color: Colors.white)), // Séparateur
            IconButton(
              onPressed: _geolocation,
              icon: Icon(Icons.location_on),
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
                const Text("Today", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(_search)

              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Week", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(_search)
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Month", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(_search)
              ],
            ),
          ),
        ],

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            _buildNavItem(Icons.wb_sunny, "Today", 0),
            _buildNavItem(Icons.today, "Week", 1),
            _buildNavItem(Icons.calendar_month, "Month", 2),
            ],
          ),
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
