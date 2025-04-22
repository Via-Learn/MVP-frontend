// auth_utils.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'routes.dart';

/// Fetches a signed token from the backend given an internal_id
Future<String?> fetchSignedAuthToken(String internalId) async {
  final response = await http.get(
    Uri.parse('$baseUrl${ApiRoutes.USERDB_POST_SIGN_TOKEN}'),
    headers: {'internal_id': internalId},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['signed_token'];
  } else {
    print("❌ Failed to sign internal_id: ${response.body}");
    return null;
  }
}
