// application/chat_service.dart
import '../data/chat_remote_datasource.dart';
import '../domain/chat_message_model.dart';
import 'dart:io';

class ChatService {
  final ChatRemoteDataSource _remote = ChatRemoteDataSource();

  Future<ChatMessage> send(String message, bool ragEnabled) {
    return _remote.sendMessage(message, ragEnabled);
  }

  Future<ChatMessage> uploadPDF(File file) {
    return _remote.uploadFile(file);
  }

  Future<String?> getFreshToken() {
    return _remote.getFreshFirebaseToken();
  }
}
