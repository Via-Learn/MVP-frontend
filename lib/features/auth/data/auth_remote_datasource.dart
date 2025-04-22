// auth_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/config.dart';
import '../../../core/constants/routes.dart';

class AuthRemoteDataSource {
  Future<Map<String, dynamic>> getUserData(String jwt) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiRoutes.USERDB_GET_ME}'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> createUser(String jwt, String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiRoutes.USERDB_POST_CREATE}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({
        "username": username,
        "profile": {"name": username, "role": "student"},
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("User creation failed: ${response.body}");
    }
  }
}
