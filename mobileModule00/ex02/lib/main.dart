import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Calculatrice'),
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
  int _counter = 0;
  String _displayValue = '0';

  void _updateDisplay(String value) {
    setState(() {
      if (value != "")
        print("button pressed: $value");
      if (_displayValue == '0') {
        _displayValue = value;
      } else {
        _displayValue += value;
      }
    });
  }

  void _clearDisplay() {
    setState(() {
      _displayValue = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Partie supérieure (bleue)
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.topRight, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "0",
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 24),
                  ),
                  Text(
                    "0",
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ),
          // Partie inférieure (calculatrice)
          Expanded(
            flex: 2,
              child: Column(
                children: [
                  // Première rangée de boutons
                  Expanded(
                    child: Row(
                      children: [
                        _buildCalculatorButton('7'),
                        _buildCalculatorButton('8'),
                        _buildCalculatorButton('9'),
                        _buildCalculatorButton('C', foregroundColor: Colors.red),
                        _buildCalculatorButton('AC', foregroundColor: Colors.red),
                    
                      ],
                    ),
                  ),
                  // Deuxième rangée de boutons
                  Expanded(
                    child: Row(
                      children: [
                        _buildCalculatorButton('4'),
                        _buildCalculatorButton('5'),
                        _buildCalculatorButton('6'),
                        _buildCalculatorButton('+', foregroundColor: Colors.white),
                        _buildCalculatorButton('-', foregroundColor: Colors.white),
                      ],
                    ),
                  ),
                  // Troisième rangée de boutons
                  Expanded(
                    child: Row(
                      children: [
                        _buildCalculatorButton('1'),
                        _buildCalculatorButton('2'),
                        _buildCalculatorButton('3'),
                        _buildCalculatorButton('x' , foregroundColor: Colors.white),
                        _buildCalculatorButton('/' , foregroundColor: Colors.white),

                      ],
                    ),
                  ),
                  // Quatrième rangée de boutons
                  Expanded(
                    child: Row(
                      children: [
                        // _buildCalculatorButton('C', onPressed: _clearDisplay, backgroundColor: Colors.grey),
                        _buildCalculatorButton('0'),
                        _buildCalculatorButton('.'),
                        _buildCalculatorButton('00'),
                        _buildCalculatorButton('=',  foregroundColor: Colors.white),
                        // _buildCalculatorButton('+', backgroundColor: const Color.fromARGB(255, 255, 0, 0)),
                        _buildCalculatorButton(""),
                      ],
                    ),
                  ),
                ],
              ),
            )
        ]
      )
    );
  }

  Widget _buildCalculatorButton(String text, {VoidCallback? onPressed, Color foregroundColor = const Color.fromARGB(255, 0, 0, 0)}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed ?? () => _updateDisplay(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 99, 98, 98),
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: Center(
          child: Text(
            text,
              style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.04, // 5% de la largeur de l'écran
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1
          ),
        ),
      ),
    );
  }
}