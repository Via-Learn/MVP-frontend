import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/routes.dart';
import '../domain/calendar_event.dart';
import '../../../core/constants/config.dart';

class CalendarController {
  Future<bool> isGoogleCalendarLinked() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    final response = await http.post(
      Uri.parse("$baseUrl${ApiRoutes.EVENTS_POST_READ}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "date": DateTime.now().toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 400 &&
        response.body.contains("Google account not linked")) {
      return false;
    }

    return true;
  }
  Future<void> connectGoogleCalendar(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  final token = await user?.getIdToken();

  final response = await http.get(
    Uri.parse("$baseUrl${ApiRoutes.GOOGLE_GET_REAUTH_URL}"),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to get reauth URL: ${response.body}");
  }

  final url = jsonDecode(response.body)['url'];
  if (url != null) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw Exception("Missing URL in response");
  }
}


  Future<List<CalendarEvent>> fetchTodayEvents(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    final nowUtc = DateTime.now().toUtc();
    final body = jsonEncode({"date": nowUtc.toIso8601String()});

    final response = await http.post(
      Uri.parse("$baseUrl${ApiRoutes.EVENTS_POST_READ}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    // ✅ Handle Google account not linked (400 error)
    if (response.statusCode == 400 &&
        response.body.contains("Google account not linked")) {
      final reauthRes = await http.get(
        Uri.parse("$baseUrl${ApiRoutes.GOOGLE_GET_REAUTH_URL}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (reauthRes.statusCode == 200) {
        final reauthUrl = jsonDecode(reauthRes.body)['url'];
        if (await canLaunchUrl(Uri.parse(reauthUrl))) {
          await launchUrl(Uri.parse(reauthUrl), mode: LaunchMode.externalApplication);
          throw Exception("Google OAuth initiated. Return after authentication.");
        } else {
          throw Exception("Could not launch reauth URL.");
        }
      } else {
        throw Exception("Failed to fetch reauth URL: ${reauthRes.body}");
      }
    }

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch events: ${response.body}");
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> eventList = decoded['events'];
    return eventList.map((e) => CalendarEvent.fromJson(e)).toList();
  }
}
