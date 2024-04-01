import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import '../services/weather_services.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class DateTimeWidget extends StatefulWidget {
  const DateTimeWidget({super.key});

  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget> {
  late String _currentDateTime;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    setState(() {
      _currentDateTime = DateTime.now().toString().substring(0, 16);//Date from year to minutes
    });
    Timer(const Duration(seconds: 1), _updateDateTime);//Updating every second for minutes
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentDateTime,
      style: const TextStyle(fontSize: 20),
    );
  }
}

class _WeatherPageState extends State<WeatherPage> {
  // Api key
  final _weatherService = WeatherService('9c776f652bf442554581e35e5b8790c4');
  Weather? _weather;

  // Fetch weather
  _fetchWeather() async {
    // Get the current city
    String cityName = await _weatherService.getCurrentCity();

    //Delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get the weather from the city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  // Get background color based on weather condition
  Color getBackgroundColor(String? mainCondition) {
    if (mainCondition == null) {
      return Colors.white; // Default color
    }
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Colors.grey.shade600; // Cloudy color
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Colors.blue.shade900; // Rainy color
      case 'clear':
        return Colors.blue.shade200; // Sunny color
      default:
        return Colors.white; // Default color
    }
  }

  // Weather animations
  Widget getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) {
      return Image.asset('assets/loading.gif'); // default
    }
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Image.asset('assets/cloudy.png');
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Image.asset('assets/rainy.png');
      case 'clear':
        return Image.asset('assets/sunny.png');
      default:
        return Image.asset('assets/sunny.png');
    }
  }

  // Init state
  @override
  void initState() {
    super.initState();

    // Fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: getBackgroundColor(_weather?.mainCondition),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // City name
              Text(
                _weather?.cityName ?? "Loading city...",
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              // Animation
              getWeatherAnimation(_weather?.mainCondition),

              // Temperature
              if (_weather != null)
                Text(
                  '${_weather?.temperature.round()}°C',
                  style: const TextStyle(fontSize: 28,),
                ),

              // Weather condition
              Text(
                _weather?.mainCondition ?? "",
                style: const TextStyle(fontSize: 24),
              ),

              // Current date and time
              if (_weather != null)
                const DateTimeWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
