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
      setState(() {
        _messages.add(response);
        _selectedFile = null;
        _selectedFileName = null;
        _selectedFileSize = null;
      });
      _scrollToBottom();
    }

    if (text.isNotEmpty) {
      final response = await _chatService.send(text, _ragEnabled);
      setState(() {
        _messages.add(response);
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _selectedFileSize = result.files.single.size;
      });
    }
  }

  void _handleNotesButtonClick() {
    if (!_notesButtonActive) {
      setState(() {
        _notesButtonActive = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload your notes to ask questions.'), behavior: SnackBarBehavior.floating),
      );
    } else {
      setState(() {
        _notesButtonActive = false;
      });
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
                          color: Colors.white,
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
                            speed: const Duration(milliseconds: 30),
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  Widget _buildFilePreview() {
    if (_selectedFileName == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _selectedFileName!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (_selectedFileSize != null) ...[
            const SizedBox(width: 6),
            Text(
              _formatBytes(_selectedFileSize!),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
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
            child: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: AppColors.inputFill,
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildFilePreview(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _handleSend,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickFile,
                tooltip: "Upload",
              ),
              ChoiceChip(
                label: const Text('Notes'),
                selected: _notesButtonActive,
                onSelected: (_) => _handleNotesButtonClick(),
                selectedColor: Colors.blueAccent,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: _notesButtonActive ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ],
          ),
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
                _buildInputBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
