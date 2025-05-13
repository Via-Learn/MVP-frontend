import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ➡️ icon
            Image.asset(
              'assets/images/applogo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 18),

            // ➡️ wordmark (without shadow)
            Image.asset(
              'assets/images/ViaLearn_Logo_Official.png',
              width: 300,
              height: 200,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 30),
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
