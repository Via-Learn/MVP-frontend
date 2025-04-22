// via_home.dart
import 'package:flutter/material.dart';

class ViaHomePage extends StatelessWidget {
  const ViaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [
                    Color(0xFF3498DB),
                    Color(0xFF695ABC),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildCard(
                    title: "Weekly Summary",
                    content: "Here's your AI-generated overview of this week's tasks, events, and important deadlines.",
                    icon: Icons.summarize,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: "Weather Forecast",
                    content: "It's currently sunny and 72°F in East Lansing. Rain expected on Thursday.",
                    icon: Icons.wb_sunny,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: "Task List (Google Tasks)",
                    content: "- Finish CSE325 Project\n- Math Quiz Friday\n- Grocery run",
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: "Notes (Google Keep)",
                    content: "- Reminder: Office hours moved to 3 PM\n- Possible exam topics: recursion, sorting",
                    icon: Icons.note_alt,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/vialearn.png',
          width: 120,
          height: 40,
          fit: BoxFit.contain,
        ),
        const Text(
          'Divya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        )
      ],
    );
  }

  Widget _buildCard({required String title, required String content, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
