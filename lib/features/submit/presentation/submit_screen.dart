import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/header.dart';
import '../../../core/constants/app_theme.dart';
import '../application/submit_service.dart';
import '../domain/assignment_model.dart';

class SubmitPage extends StatelessWidget {
  const SubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubmitController()..initialize(),
      child: Consumer<SubmitController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final theme = Theme.of(context);
          final textTheme = theme.textTheme;
          final colorScheme = theme.colorScheme;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  const AppHeader(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: controller.courses.map<Widget>((course) {
                        final courseId = course['id'];
                        final assignments = controller.assignmentsByCourse[courseId] ?? [];
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
                                controller,
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
