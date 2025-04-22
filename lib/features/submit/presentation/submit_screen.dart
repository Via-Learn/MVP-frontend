import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.5,
                        colors: [Color(0xFF3498DB), Color(0xFF695ABC)],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/vialearn.png', width: 120, height: 40),
                            const Text("Divya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: controller.courses.map<Widget>((course) {
                            final courseId = course['id'];
                            final assignments = controller.assignmentsByCourse[courseId] ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                ...List.generate(assignments.length, (index) {
                                  return _buildAssignmentCard(assignments[index], courseId, index, controller);
                                }),
                                const SizedBox(height: 20),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
    Assignment assignment,
    int courseId,
    int index,
    SubmitController controller,
  ) {
    String status = assignment.status;
    Color badgeColor = switch (status.toLowerCase()) {
      'submitted' => Colors.green,
      'scheduled' => Colors.orange,
      _ => Colors.grey
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Assignment: ${assignment.title}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Due: ${assignment.dueDate}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status, style: TextStyle(color: badgeColor)),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.handleSubmit(courseId, index),
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Upload"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
