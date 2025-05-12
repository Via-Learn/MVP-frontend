import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/config.dart';

class BackendClient {
  static final BackendClient _instance = BackendClient._internal();
  factory BackendClient() => _instance;
  BackendClient._internal();

  Future<String> _getAuthToken() async {
    return await AuthHelpers.getFreshIdToken();
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {dynamic body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(body ?? {}));
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(url, headers: headers, body: jsonEncode(body ?? {}));
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: headers);
  }

  Future<http.StreamedResponse> multipart(String endpoint, Map<String, String> fields, List<http.MultipartFile> files) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl$endpoint');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    fields.forEach((key, value) {
      request.fields[key] = value;
    });
    request.files.addAll(files);

    return await request.send();
  }
}

class AuthHelpers {
  static Future<String> getFreshIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    final idToken = await user.getIdToken(true);
    
    print("🔐 JWT Token: $idToken"); // ✅ DEBUG ONLY
    return idToken!;
  }
}

