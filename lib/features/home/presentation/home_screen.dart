// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/header.dart';
import '../application/calendar_controller.dart';
import '../domain/calendar_event.dart';

class ViaHomePage extends StatefulWidget {
  const ViaHomePage({super.key});

  @override
  State<ViaHomePage> createState() => _ViaHomePageState();
}

class _ViaHomePageState extends State<ViaHomePage> {
  String _weatherDescription = "Loading...";
  double _temperature = 0;
  String _city = "Fetching location...";
  List<CalendarEvent> _events = [];
  Set<String> _completedEvents = {};
  bool _loadingEvents = true;
  String _userName = "";
  String _todayKey = "";
  bool _isCalendarLinked = true;

  @override
  void initState() {
    super.initState();
    _todayKey = _getTodayKey();
    _loadCompletedEvents();
    _loadUserName();
    _fetchWeather();
    _fetchCalendarEvents();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> _fetchCalendarEvents() async {
  try {
    final linked = await CalendarController().isGoogleCalendarLinked();
    if (!linked) {
      setState(() {
        _isCalendarLinked = false;
        _loadingEvents = false;
      });
      return;
    }

    final events = await CalendarController().fetchTodayEvents(context);
    setState(() {
      _events = events;
      _isCalendarLinked = true;
      _loadingEvents = false;
    });
  } catch (e) {
    print("❌ Calendar load error: $e");
    setState(() {
      _isCalendarLinked = false; // <- important fallback
      _loadingEvents = false;
    });
  }
}


  Future<void> _loadCompletedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "completedEvents_$_todayKey";
    setState(() {
      _completedEvents = (prefs.getStringList(key) ?? []).toSet();
    });
  }

  Future<void> _saveCompletedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("completedEvents_$_todayKey", _completedEvents.toList());
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
    const apiKey = '80f9429c61e3c82a194218ac1da86b6e';
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=imperial');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _temperature = data['main']['temp'];
          _weatherDescription = data['weather'][0]['description'];
          _city = data['name'];
        });
      }
    } catch (e) {
      print("Weather fetch error: $e");
    }
  }
  
  Future<void> _connectGoogleCalendar() async {
  try {
    await CalendarController().connectGoogleCalendar(context);
    await _fetchCalendarEvents(); // refresh events after successful link
  } catch (e) {
    print("❌ Calendar auth failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to link calendar.")),
    );
  }
}


  Future<void> _toggleEventCompleted(String eventId) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_completedEvents.contains(eventId)) {
        _completedEvents.remove(eventId);
      } else {
        _completedEvents.add(eventId);
      }
    });

    await prefs.setStringList("completedEvents_$_todayKey", _completedEvents.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final pendingEvents = _events.where((e) => !_completedEvents.contains(e.id)).toList();
    final completedEvents = _events.where((e) => _completedEvents.contains(e.id)).toList();

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
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loadingEvents
                  ? const Center(child: CircularProgressIndicator())
                  : !_isCalendarLinked
                      ? _buildConnectCalendarPrompt()
                      : _buildEventsGrouped(pendingEvents, completedEvents, theme, textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectCalendarPrompt() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await _connectGoogleCalendar();
        },
        icon: const Icon(Icons.link),
        label: const Text("Connect Google Calendar"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                _city,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  

  Widget _buildEventsGrouped(List<CalendarEvent> pending, List<CalendarEvent> completed, ThemeData theme, TextTheme textTheme) {
  if (!_isCalendarLinked) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _connectGoogleCalendar,
        icon: const Icon(Icons.link),
        label: const Text("Connect Google Calendar"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  return ListView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    children: [
      if (pending.isNotEmpty) ...[
        Text("Pending", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...pending.map((e) => _buildEventTile(e, false, theme, textTheme)),
      ],
      if (completed.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text("Completed", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...completed.map((e) => _buildEventTile(e, true, theme, textTheme)),
      ]
    ],
  );
}


  Widget _buildEventTile(CalendarEvent event, bool isCompleted, ThemeData theme, TextTheme textTheme) {
    return AnimatedOpacity(
      opacity: isCompleted ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (_) => _toggleEventCompleted(event.id),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.summary,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${event.localStartTime} – ${event.localEndTime}",
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
  }
}
