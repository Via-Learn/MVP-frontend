import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/widgets/header.dart';

class ViaSubmitNotice extends StatelessWidget {
  const ViaSubmitNotice({super.key});

  Future<String> _buildBody() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final school = prefs.getString('school') ?? 'your school';
    final name = user?.displayName ?? 'a student';

    return Uri.encodeComponent(
      'Hey ViaLearn,\n\nI’m $name from $school and I want to use ViaSubmit!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    const email = 'info@viaveri.co';
    final subject = Uri.encodeComponent('ViaSubmit Access Request');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      const SizedBox(height: 20),
                      Text(
                        "Contact your teacher for access to ViaSubmit.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final body = await _buildBody();
                          final mailtoLink = 'mailto:$email?subject=$subject&body=$body';
                          final success = await launchUrlString(mailtoLink);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Unable to open mail app")),
                            );
                          }
                        },
                        icon: const Icon(Icons.email_outlined),
                        label: const Text("Email ViaLearn"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
