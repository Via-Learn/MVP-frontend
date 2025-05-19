import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/header.dart';
import '../../../core/constants/app_theme.dart';
import '../application/submit_service.dart';
import '../domain/assignment_model.dart';
import '../application/lms_controller.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final List<String> _lmsOptions = ['Canvas'];
  String _selectedLms = 'Canvas';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubmitController()),
        ChangeNotifierProvider(create: (_) => LMSController()),
      ],
      child: Consumer2<SubmitController, LMSController>(
        builder: (context, submitController, lmsController, _) {
          final theme = Theme.of(context);
          final textTheme = theme.textTheme;
          final colorScheme = theme.colorScheme;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  const AppHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select LMS:',
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedLms,
                          borderRadius: BorderRadius.circular(12),
                          items: _lmsOptions.map((String lms) {
                            return DropdownMenuItem<String>(
                              value: lms,
                              child: Text(lms),
                            );
                          }).toList(),
                          onChanged: (String? newValue) async {
                            if (newValue == 'Canvas') {
                              await lmsController.handleReauth(context);
                              // After successful OAuth, trigger load
                              await submitController.loadCanvasCoursesIfLinked();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: submitController.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : submitController.courses.isEmpty
                            ? Center(
                                child: Text(
                                  'No courses available. Please link your LMS or enroll in a Canvas course.',
                                  style: textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                children: submitController.courses.map<Widget>((course) {
                                  final courseId = course['id'];
                                  final assignments = submitController.assignmentsByCourse[courseId] ?? [];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course['name'],
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onBackground,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ...List.generate(assignments.length, (index) {
                                        return _buildAssignmentCard(
                                          context,
                                          assignments[index],
                                          courseId,
                                          index,
                                          submitController,
                                        );
                                      }),
                                      const SizedBox(height: 24),
                                    ],
                                  );
                                }).toList(),
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    Assignment assignment,
    int courseId,
    int index,
    SubmitController controller,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    String status = assignment.status;
    Color badgeColor = switch (status.toLowerCase()) {
      'submitted' => Colors.green,
      'scheduled' => Colors.orange,
      _ => Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Assignment: ${assignment.title}",
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Due: ${assignment.dueDate}",
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.handleSubmit(courseId, index),
                icon: const Icon(Icons.attach_file),
                label: const Text("Upload"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
