// features/plan/data/plan_remote_datasource.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/config.dart';
import '../../../core/constants/routes.dart';
import '../../../core/network/backend_client.dart';
import '../domain/event_model.dart';

class PlanRemoteDataSource {
  final BackendClient _client;

  PlanRemoteDataSource({BackendClient? client})
      : _client = client ?? BackendClient();

  Future<List<EventModel>> extractEventsFromPDF(File file) async {
    var multipartResponse = await _client.multipart(
      ApiRoutes.EVENTS_POST_EXTRACT,
      {},
      [await http.MultipartFile.fromPath('file', file.path)],
    );

    final response = await http.Response.fromStream(multipartResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['events'])
          .map(EventModel.fromJson)
          .toList();
    } else {
      throw Exception("Failed to extract events: ${response.body}");
    }
  }

  Future<void> addEventToCalendar(EventModel event) async {
    final response = await _client.post(
      ApiRoutes.EVENTS_POST_CREATE,
      body: [event.toJson()], // Send a list with one event
    );

    if (response.statusCode == 401 || response.body.contains("not linked")) {
      await handleOAuthReauth(() => addEventToCalendar(event));
    } else if (response.statusCode != 200) {
      throw Exception(
          "Calendar add failed: ${response.statusCode}: ${response.body}");
    }
  }

  Future<void> handleOAuthReauth(Future<void> Function() callback) async {
    final response = await _client.get(ApiRoutes.GOOGLE_GET_REAUTH_URL);

    if (response.statusCode == 200) {
      final authUrl = jsonDecode(response.body)['auth_url'];
      if (authUrl != null) {
        await launchUrl(Uri.parse(authUrl),
            mode: LaunchMode.externalApplication);
        await Future.delayed(const Duration(seconds: 5));
        await callback();
      }
    } else {
      throw Exception("Failed to get reauth URL: ${response.body}");
    }
  }
}
