import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/header.dart';
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

  String _sanitizeText(String input) {
    return input.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
  }

  Widget _buildEventCard(EventModel event) {
    final isAdded = _added.contains(event.title);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(
          _sanitizeText(event.title),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${event.type} — ${event.date}"),
        trailing: IconButton(
          icon: Icon(
            isAdded ? Icons.check_circle : Icons.add_circle_outline,
            color: isAdded ? Colors.green : Theme.of(context).colorScheme.primary,
          ),
          onPressed: isAdded ? null : () => _addToCalendar(event),
        ),
        onTap: () => _addToCalendar(event),
      ),
    );
  }

  Widget _buildEventList() {
    if (_events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text("📄 Upload a PDF schedule to view events."),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _events.length,
      itemBuilder: (context, index) => _buildEventCard(_events[index]),
    );
  }

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: ElevatedButton.icon(
        onPressed: _pickAndUploadFile,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Schedule PDF'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
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
            _buildUploadSection(),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
    );
  }
}
