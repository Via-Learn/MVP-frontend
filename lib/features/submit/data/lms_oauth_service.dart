import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/config.dart';
import '../../../core/constants/routes.dart';
import '../../../core/network/backend_client.dart';

class LMSOAuthService {
  final BackendClient _client;

  LMSOAuthService({BackendClient? client}) : _client = client ?? BackendClient();

  Future<String> getCanvasReauthUrl(String baseUrl) async {
    final response = await _client.post(ApiRoutes.CANVAS_POST_REAUTH, body: {
      "base_url": baseUrl,
    });

    if (response.statusCode != 200) {
      throw Exception("Canvas reauth failed: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data['auth_url']; // <- Canvas auth URL to open in browser
  }
}
