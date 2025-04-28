import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_theme.dart';
import '../application/plan_service.dart';
import '../domain/event_model.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final PlanService _service = PlanService();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _added = {};
  List<EventModel> _events = [];
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

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      try {
        final extracted = await _service.uploadAndExtractEvents(file);
        setState(() => _events = extracted);
        _scrollToBottom();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule uploaded!'), behavior: SnackBarBehavior.floating),
        );
      } catch (e) {
        print("❌ Error: $e");
      }
    }
  }

  Future<void> _addToCalendar(EventModel event) async {
    try {
      await _service.addEvent(event);
      setState(() => _added.add(event.title));
    } catch (e) {
      print("❌ Add to calendar failed: $e");
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

  Widget _buildEventCard(EventModel event) {
    final isAdded = _added.contains(event.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${event.type} — ${event.date}",
                  style: const TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isAdded ? Icons.check_circle : Icons.add_circle_outline,
              color: isAdded ? Colors.green : AppColors.primary,
            ),
            onPressed: isAdded ? null : () => _addToCalendar(event),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.all(16),
    color: AppColors.background,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/vialearn.png', width: 120, height: 40),
        Text(
          _userName.isEmpty ? "..." : _userName,
          style: TextStyle(
            color: AppColors.secondary, 
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.white),
            onPressed: _pickAndUploadFile,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Upload a schedule to plan...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) => _buildEventCard(_events[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildEventList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }
}
