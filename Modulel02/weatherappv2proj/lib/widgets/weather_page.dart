import 'package:flutter/material.dart';

class WeatherPage extends StatelessWidget {
  final String title;
  final String search;
  final TextStyle textStyle;

  const WeatherPage({
    super.key,
    required this.title,
    required this.search,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (search != "Geolocation is not available, please enable it in your app settings")
            Text(
              title,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          Text(
            search,
            style: textStyle,
          )
        ],
      ),
    );
  }
}
