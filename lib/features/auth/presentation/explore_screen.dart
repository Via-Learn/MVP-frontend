import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ➡️ icon (same for both themes)
            Image.asset(
              'assets/images/vialearnnew.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),

            // ➡️ wordmark with shadow (via Stack)
            Stack(
              children: [
                // Shadow layer
                Positioned(
                  top: 3,
                  left: 3,
                  child: Image.asset(
                    'assets/images/vialearn2.png',
                    width: 300,
                    height: 80,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
                // Actual logo
                Image.asset(
                  'assets/images/vialearn2.png',
                  width: 300,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),

            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
