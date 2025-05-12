// home/data/calendar_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/calendar_event.dart';

class CalendarService {
  final String apiUrl = 'https://your-backend-url.com/events/read';

  Future<List<CalendarEvent>> getEventsForDate(DateTime date, String token) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'date': date.toIso8601String()}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<CalendarEvent>.from(
        data['events'].map((e) => CalendarEvent.fromJson(e)),
      );
    } else {
      throw Exception("Failed to fetch events: ${response.body}");
    }
  }
}
