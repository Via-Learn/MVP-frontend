import 'dart:convert';
import '../../../core/constants/routes.dart';
import '../../../core/network/backend_client.dart';

class AuthRemoteDataSource {
  final BackendClient _backend = BackendClient();

  Future<Map<String, dynamic>> getUserData(String jwt) async {
    final response = await _backend.get(ApiRoutes.USERDB_GET_ME); // ✅ no headers
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> createUser(String jwt, String username) async {
    final response = await _backend.post(
      ApiRoutes.USERDB_POST_CREATE,
      body: {
        "username": username,
        "profile": {"name": username, "role": "student"},
      },
    ); // ✅ no headers

    if (response.statusCode != 200) {
      throw Exception("User creation failed: ${response.body}");
    }
  }
}
