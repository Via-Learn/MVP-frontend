// data/chat_remote_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/config.dart';
import '../../../core/constants/routes.dart';
import '../domain/chat_message_model.dart';

class ChatRemoteDataSource {
  Future<String?> getFreshFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken(true);
  }

  Future<ChatMessage> sendMessage(String message, bool ragEnabled) async {
    final token = await getFreshFirebaseToken();
    if (token == null) return ChatMessage(text: "❌ Not authenticated.", sender: 'bot');

    final endpoint = ragEnabled
        ? '$baseUrl${ApiRoutes.LLM_POST_RAG}'
        : '$baseUrl${ApiRoutes.LLM_POST_CHAT}';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'user_input': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatMessage(
        text: data['assistant_reply'] ?? "🤖 No response.",
        sender: 'bot',
        sources: List<String>.from(data['citations'] ?? []),
      );
    } else {
      return ChatMessage(
        text: "⚠️ Error ${response.statusCode}: ${response.body}",
        sender: 'bot',
      );
    }
  }

  Future<ChatMessage> uploadFile(File file) async {
    final token = await getFreshFirebaseToken();
    if (token == null) return ChatMessage(text: "❌ Not authenticated.", sender: 'bot');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl${ApiRoutes.LLM_POST_EMBED}'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    return ChatMessage(
      text: response.statusCode == 200
          ? "📄 PDF uploaded successfully!"
          : "❌ Upload failed: $responseBody",
      sender: 'bot',
    );
  }
}
