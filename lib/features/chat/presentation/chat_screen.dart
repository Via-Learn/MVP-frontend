import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/widgets/header.dart';
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

  bool _notesButtonActive = false;
  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;

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
  if (text.isEmpty && _selectedFile == null) return;

  if (text.isNotEmpty) {
    setState(() {
      _messages.add(ChatMessage(text: text, sender: 'user'));
      _isLoading = true;
    });
  }

  _inputController.clear();
  _scrollToBottom();

  if (_selectedFile != null) {
    final response = await _chatService.uploadPDF(_selectedFile!);

    // ✅ Only show error or important upload messages
    final normalizedText = response.text.toLowerCase();
    if (!normalizedText.contains("uploaded successfully")) {
      setState(() {
        _messages.add(response);
      });
    }

    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
      _selectedFileSize = null;
    });

    _scrollToBottom();
  }

  if (text.isNotEmpty) {
    // final response = await _chatService.send(text, _ragEnabled);
    final response = await _chatService.send(text, _notesButtonActive);
    setState(() {
      _messages.add(response);
      _isLoading = false;
    });
    _scrollToBottom();
  }
}

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _selectedFileSize = result.files.single.size;
      });
    }
  }

  void _handleNotesButtonClick() {
    setState(() {
      _notesButtonActive = !_notesButtonActive;
    });
    if (_notesButtonActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload your notes to ask questions.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
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
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.all(10),
    itemCount: _messages.length + (_isLoading ? 1 : 0),
    itemBuilder: (context, index) {
      if (_isLoading && index == _messages.length) return _loadingBubble();

      final msg = _messages[index];
      final isUser = msg.sender == 'user';

      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser
                ? (isDark ? const Color(0xFF6D88FF) : const Color(0xFFD6E4FF))
                : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F2F2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isUser
              ? Text(
                  msg.text,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MarkdownBody(
                            data: msg.text,
                            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                              p: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 18, color: isDark ? Colors.white60 : Colors.black54),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: msg.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (msg.sources != null && msg.sources!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 16, color: Colors.deepPurple),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Sources'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: msg.sources!.map((source) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text("• $source", style: const TextStyle(fontSize: 14)),
                                      );
                                    }).toList(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              'View sources',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      ),
                    ]
                  ],
                ),
        ),
      );
    },
  );
}




  Widget _loadingBubble() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedTextKit(
          animatedTexts: [TyperAnimatedText("...", speed: const Duration(milliseconds: 200))],
          repeatForever: true,
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  Widget _buildFilePreview(bool isDark) {
    if (_selectedFileName == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _selectedFileName!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
            ),
          ),
          if (_selectedFileSize != null) ...[
            const SizedBox(width: 6),
            Text(
              _formatBytes(_selectedFileSize!),
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
            ),
          ],
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedFile = null;
                _selectedFileName = null;
                _selectedFileSize = null;
              });
            },
            child: Icon(Icons.close, size: 18, color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5EBFF);
    final inputColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildFilePreview(isDark),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: inputColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.deepPurple),
                onPressed: _handleSend,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file, color: textColor),
                onPressed: _pickFile,
              ),
              ChoiceChip(
                label: const Text('Notes'),
                selected: _notesButtonActive,
                onSelected: (_) => _handleNotesButtonClick(),
                selectedColor: Colors.deepPurple,
                backgroundColor: inputColor,
                labelStyle: TextStyle(
                  color: _notesButtonActive ? Colors.white : textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(child: _buildChatMessages()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }
}
