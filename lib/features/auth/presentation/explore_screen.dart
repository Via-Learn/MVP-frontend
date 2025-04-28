import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class ExploreScreen extends StatelessWidget {
  final Color backgroundColor;
  final Color accentColor;

  const ExploreScreen({
    super.key,
    this.backgroundColor = AppColors.background, // default to app background
    this.accentColor = AppColors.primary,         // default to primary color
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Simple background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 150, height: 150),
            const SizedBox(height: 30),
            Image.asset('assets/images/vialearn.png', width: 300, height: 80, fit: BoxFit.contain),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor, // 🟦 Button color custom
              ),
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text(
                'Sign Up / Log In',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
