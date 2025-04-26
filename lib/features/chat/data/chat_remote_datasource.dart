import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/routes.dart';
import '../../../core/network/backend_client.dart'; // << backend wrapper
import '../domain/chat_message_model.dart';

class ChatRemoteDataSource {
  final BackendClient _backend = BackendClient();

  Future<String?> getFreshFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken(true);
  }

  Future<ChatMessage> sendMessage(String message, bool ragEnabled) async {
    final endpoint = ragEnabled
        ? ApiRoutes.LLM_POST_RAG
        : ApiRoutes.LLM_POST_CHAT;

    final response = await _backend.post(endpoint, body: {'user_input': message});

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
    final fileName = file.path.split('/').last;
    final multipartFile = await http.MultipartFile.fromPath('file', file.path);

    final response = await _backend.multipart(
      ApiRoutes.LLM_POST_EMBED,
      {'filename': fileName},
      [multipartFile],
    );

    final responseBody = await response.stream.bytesToString();

    return ChatMessage(
      text: response.statusCode == 200
          ? "📄 PDF uploaded successfully!"
          : "❌ Upload failed: $responseBody",
      sender: 'bot',
    );
  }
}
