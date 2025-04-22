// domain/chat_message_model.dart
class ChatMessage {
  final String text;
  final String sender;
  final List<String>? sources;

  ChatMessage({required this.text, required this.sender, this.sources});
}
