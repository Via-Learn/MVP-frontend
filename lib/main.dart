// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/firebase_options.dart';
import 'features/auth/presentation/explore_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/chat/presentation/chat_screen.dart';         // still available directly if needed
import 'navigation/home_shell.dart';  // new navigation wrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ViaLearn Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExploreScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/chat': (context) => const ChatScreen(),   // direct if needed
        '/home': (context) => const HomeShell(),    // ⬅️ NEW nav wrapper!
      },
    );
  }
}
