import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_theme.dart'; // <-- centralized theme/colors
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
        color: AppColors.inputFill.withOpacity(0.95), // centralized card background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  "${event.type} — ${event.date}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isAdded ? Icons.check_circle : Icons.add_circle_outline,
              color: isAdded ? Colors.green : AppColors.primary, // use AppColors.primary
            ),
            onPressed: isAdded ? null : () => _addToCalendar(event),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/vialearn.png', width: 120, height: 40),
          const Text(
            "Divya",
            style: TextStyle(
              color: Colors.white,
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
      padding: const EdgeInsets.all(10),
      color: AppColors.inputFill, // centralized input background
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickAndUploadFile),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Upload a schedule to plan...',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
      padding: const EdgeInsets.all(10),
      itemCount: _events.length,
      itemBuilder: (context, index) => _buildEventCard(_events[index]),
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
                  colors: [
                    AppColors.gradientStart,
                    AppColors.gradientEnd,
                  ],
                ),
              ),
            ),
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildEventList()),
                _buildInputBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
