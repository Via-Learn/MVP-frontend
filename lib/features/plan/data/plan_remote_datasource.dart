// features/plan/data/plan_remote_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/config.dart';
import '../../../core/constants/routes.dart';
import '../domain/event_model.dart';

class PlanRemoteDataSource {
  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken(true);
  }

  Future<List<EventModel>> extractEventsFromPDF(File file) async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl${ApiRoutes.EVENTS_POST_EXTRACT}'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['events']).map(EventModel.fromJson).toList();
    } else {
      throw Exception("Failed to extract events: ${response.body}");
    }
  }

  Future<void> addEventToCalendar(EventModel event) async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.post(
      Uri.parse('$baseUrl${ApiRoutes.EVENTS_POST_CREATE}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode([{
        'title': event.title,
        'type': event.type,
        'date': event.date,
      }]),
    );

    if (response.statusCode == 401 || response.body.contains("not linked")) {
      await handleOAuthReauth(() => addEventToCalendar(event));
    } else if (response.statusCode != 200) {
      throw Exception("Calendar add failed: ${response.statusCode}: ${response.body}");
    }
  }

  Future<void> handleOAuthReauth(Function callback) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl${ApiRoutes.GOOGLE_GET_REAUTH_URL}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final authUrl = jsonDecode(response.body)['auth_url'];
      if (authUrl != null) {
        await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
        await Future.delayed(const Duration(seconds: 5));
        await callback();
      }
    } else {
      throw Exception("Failed to get reauth URL: ${response.body}");
    }
  }
}
