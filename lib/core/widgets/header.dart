import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "User";
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/ViaLearn_Logo_Official.png', width: 120, height: 40),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Text(
                  userName,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.brightness_6),
                color: Theme.of(context).colorScheme.onSurface,
                onPressed: () {
                  final provider = Provider.of<ThemeProvider>(context, listen: false);
                  provider.toggleTheme();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
