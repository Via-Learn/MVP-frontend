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

  try {
    final response = await _backend.post(endpoint, body: {'user_input': message});
    print('📡 Response status: ${response.statusCode}');
    print('📩 Raw body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      print('🧾 Assistant reply: ${data['assistant_reply']}');
      print('📚 Citations: ${data['citations']}');

      print('🧾 Decoded JSON: $data');

      final botReply = data['assistant_reply'] ?? data['response'] ?? '';

      if (botReply.trim().isEmpty) {
        print('❗ Warning: Empty bot reply text');
      }

      final rawCitations = data['citations'];
      List<String> parsedCitations = [];

      if (rawCitations is String) {
        parsedCitations = rawCitations
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (rawCitations is List) {
        parsedCitations = List<String>.from(rawCitations);
      }

      return ChatMessage(
        text: botReply.isEmpty ? "🤖 No reply received." : botReply,
        sender: 'bot',
        sources: parsedCitations,
      );

    } else {
      print('❌ Server error: ${response.statusCode}');
      return ChatMessage(
        text: "⚠️ Server error: ${response.statusCode}",
        sender: 'bot',
      );
    }
  } catch (e, stackTrace) {
    print('💥 Exception: $e');
    print(stackTrace);
    return ChatMessage(
      text: "🚨 Error occurred while sending message.",
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
