import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/header.dart';
import '../../../core/constants/app_theme.dart';

class ViaGradePage extends StatefulWidget {
  const ViaGradePage({super.key});

  @override
  State<ViaGradePage> createState() => _ViaGradePageState();
}

class _ViaGradePageState extends State<ViaGradePage> {
  File? _questionPaper;
  File? _studentWriteup;
  bool _loading = false;
  Map<String, dynamic>? _feedback;

  Future<void> _pickFile(bool isQuestionPaper) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isQuestionPaper) {
          _questionPaper = File(result.files.single.path!);
        } else {
          _studentWriteup = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _submitForGrading() async {
    if (_questionPaper == null || _studentWriteup == null) return;

    setState(() => _loading = true);

    try {
      // TODO: Replace this with actual API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _feedback = {
          "completion_status": "complete",
          "rubric_checks": [
            {
              "rubric_item": "Clarity",
              "status": "satisfied",
              "text_snippet": "The argument is presented clearly.",
              "suggestion": "Continue with this structure."
            },
            {
              "rubric_item": "Grammar",
              "status": "needs work",
              "text_snippet": "There are some grammar errors.",
              "suggestion": "Proofread the third paragraph."
            }
          ],
          "overall_feedback": "Great effort! Focus on grammar improvements."
        };
      });
    } catch (e) {
      print("Error grading: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to grade submission."),
      ));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Submit for Grading", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _buildFilePicker("Upload Question Paper", _questionPaper, true),
            _buildFilePicker("Upload Student Writeup", _studentWriteup, false),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: (_questionPaper != null && _studentWriteup != null && !_loading)
                    ? _submitForGrading
                    : null,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(_loading ? "Submitting..." : "Submit for Autograde"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildFeedbackSection(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker(String label, File? file, bool isQuestionPaper) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () => _pickFile(isQuestionPaper),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFFF5EBFF),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: file != null ? Colors.blue : Colors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file?.path.split('/').last ?? label,
                  style: TextStyle(color: file != null ? Colors.black : Colors.black),
                ),
              ),
              const Icon(Icons.edit, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(ThemeData theme) {
    if (_feedback == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          Text("Feedback Summary", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...(_feedback!['rubric_checks'] as List).map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📝 ${item['rubric_item']}", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  Text("Status: ${item['status']}", style: TextStyle(color: item['status'] == "satisfied" ? Colors.green : Colors.orange)),
                  const SizedBox(height: 6),
                  Text("📌 Snippet: ${item['text_snippet']}"),
                  Text("💡 Suggestion: ${item['suggestion']}"),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
          Text("✅ Overall Feedback", style: theme.textTheme.titleSmall),
          Text(_feedback!['overall_feedback'] ?? ""),
        ],
      ),
    );
  }
}
