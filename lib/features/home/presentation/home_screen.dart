import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ⬅️ Import Firebase auth
import '../../../core/constants/app_theme.dart'; // centralized colors

class ViaHomePage extends StatefulWidget {
  const ViaHomePage({super.key});

  @override
  State<ViaHomePage> createState() => _ViaHomePageState();
}

class _ViaHomePageState extends State<ViaHomePage> {
  // Example Weather Data
  String _weatherDescription = "Sunny";
  double _temperature = 72;
  String _city = "East Lansing";

  // Example Event Data
  List<Map<String, dynamic>> _events = [
    {'id': '1', 'title': 'CSE 491 Exam', 'start': '2:00 PM', 'end': '5:00 PM', 'location': 'Wells Hall'},
    {'id': '2', 'title': 'Team Meeting', 'start': '7:00 PM', 'end': '8:00 PM', 'location': 'Library'},
    {'id': '3', 'title': 'Grocery Run', 'start': '6:00 PM', 'end': '7:00 PM', 'location': 'Meijer'},
  ];

  Set<String> _completedEvents = {}; // Set of completed event IDs
  String _userName = ""; // ⬅️ Firebase user name

  @override
  void initState() {
    super.initState();
    _loadCompletedEvents();
    _loadUserName();
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
        _userName = user.displayName ?? "User"; // fallback if no display name
      });
    }
  }

  Future<void> _toggleEventCompleted(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedEvents.add(eventId);
      _events.removeWhere((event) => event['id'] == eventId); // 🆕 remove event when completed
      prefs.setStringList('completedEvents', _completedEvents.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.6,
                  colors: [
                    AppColors.gradientStart,
                    AppColors.gradientEnd,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(), // 🆕 Logo + dynamic Username
                  const SizedBox(height: 20),
                  _buildWeatherCard(),
                  const SizedBox(height: 20),
                  const Text(
                    "Today's Events",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _buildEventsList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/vialearn.png',
          width: 120,
          height: 40,
          fit: BoxFit.contain,
        ),
        Text(
          _userName.isEmpty ? "..." : _userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, size: 40, color: Colors.orange),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$_temperature°F • $_weatherDescription",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                _city,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_events.isEmpty) {
      return const Center(
        child: Text(
          "🎉 All events completed!",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.inputFill.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Checkbox(
                value: false,
                onChanged: (_) => _toggleEventCompleted(event['id']),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${event['start']} - ${event['end']}  •  ${event['location']}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
