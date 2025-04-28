import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_theme.dart';
import '../application/chat_service.dart';
import '../domain/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _ragEnabled = false;
  bool _isLoading = false;
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? "User";
      });
    }
  }

  void _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, sender: 'user'));
      _isLoading = true;
    });

    _inputController.clear();
    _scrollToBottom();

    final response = await _chatService.send(text, _ragEnabled);

    setState(() {
      _messages.add(response);
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      final response = await _chatService.uploadPDF(File(result.files.single.path!));
      setState(() => _messages.add(response));
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _loadingBubble();
        }

        final msg = _messages[index];
        final isUser = msg.sender == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.primary.withOpacity(1)
                      : AppColors.inputFill.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isUser
                    ? Text(
                        msg.text,
                        style: const TextStyle(
                          color: Colors.white, // 🆕 User message text white
                          fontSize: 16,
                        ),
                      )
                    : AnimatedTextKit(
                        isRepeatingAnimation: false,
                        animatedTexts: [
                          TyperAnimatedText(
                            msg.text,
                            textStyle: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            speed: const Duration(milliseconds: 30), // Typing speed
                          ),
                        ],
                      ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUser && msg.sources != null && msg.sources!.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.menu_book, size: 18, color: Colors.white),
                      label: const Text("View Sources", style: TextStyle(color: Colors.white)),
                      onPressed: () => _showSourcesModal(context, msg.sources!),
                    ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: msg.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard!')),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _loadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputFill.withOpacity(0.95),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedTextKit(
          animatedTexts: [TyperAnimatedText("...", speed: const Duration(milliseconds: 200))],
          repeatForever: true,
        ),
      ),
    );
  }

  void _showSourcesModal(BuildContext context, List<String> sources) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sources.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) => Text("• ${sources[index]}"),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: AppColors.inputFill,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFile),
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _handleSend),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/vialearn.png', width: 120, height: 40),
          Text(
            _userName.isEmpty ? "..." : _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRagToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: AppColors.inputFill,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("SYNC OFF"),
          Switch(
            value: _ragEnabled,
            onChanged: (v) => setState(() => _ragEnabled = v),
          ),
          const Text("SYNC ON"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
              ),
            ),
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildChatMessages()),
                _buildRagToggle(),
                _buildInputBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
