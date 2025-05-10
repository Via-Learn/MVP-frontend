import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/header.dart';

class ViaHomePage extends StatefulWidget {
  const ViaHomePage({super.key});

  @override
  State<ViaHomePage> createState() => _ViaHomePageState();
}

class _ViaHomePageState extends State<ViaHomePage> {
  String _weatherDescription = "Loading...";
  double _temperature = 0;
  String _city = "Fetching location...";

  List<Map<String, dynamic>> _events = [
    {'id': '1', 'title': 'CSE 491 Exam', 'start': '2:00 PM', 'end': '5:00 PM', 'location': 'Wells Hall'},
    {'id': '2', 'title': 'Team Meeting', 'start': '7:00 PM', 'end': '8:00 PM', 'location': 'Library'},
    {'id': '3', 'title': 'Grocery Run', 'start': '6:00 PM', 'end': '7:00 PM', 'location': 'Meijer'},
  ];

  Set<String> _completedEvents = {};
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _loadCompletedEvents();
    _loadUserName();
    _fetchWeather();
  }

  Future<void> _loadCompletedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedEvents = (prefs.getStringList('completedEvents') ?? []).toSet();
    });
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? "User";
      });
    }
  }

  Future<void> _fetchWeather() async {
    const String apiKey = '80f9429c61e3c82a194218ac1da86b6e';

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print("Location permission denied");
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=imperial');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _temperature = data['main']['temp'];
          _weatherDescription = data['weather'][0]['description'];
          _city = data['name'];
        });
      } else {
        print("Failed to fetch weather: ${response.statusCode}");
      }
    } catch (e) {
      print("Weather fetch error: $e");
    }
  }

  Future<void> _toggleEventCompleted(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedEvents.add(eventId);
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _events.removeWhere((event) => event['id'] == eventId);
    });
    prefs.setStringList('completedEvents', _completedEvents.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildWeatherCard(theme),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Today's Events",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildEventsList(theme, textTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_rounded, size: 36, color: Colors.orange),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_temperature.toStringAsFixed(1)}°F • $_weatherDescription",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _city,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(ThemeData theme, TextTheme textTheme) {
    if (_events.isEmpty) {
      return const Center(
        child: Text("🎉 All events completed!", style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.separated(
      itemCount: _events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final event = _events[index];
        final isChecked = _completedEvents.contains(event['id']);
        return AnimatedOpacity(
          opacity: isChecked ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (_) => _toggleEventCompleted(event['id']),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${event['start']} – ${event['end']}  •  ${event['location']}",
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}