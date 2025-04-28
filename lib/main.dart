// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/firebase_options.dart';
import 'core/constants/app_theme.dart'; // <-- import centralized theme
import 'features/auth/presentation/explore_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'navigation/home_shell.dart'; // navigation wrapper

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
      theme: AppTheme.lightTheme, // <-- use your AppTheme instead of ThemeData inline
      debugShowCheckedModeBanner: false, // optional: remove debug banner
      home: const ExploreScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/chat': (context) => const ChatScreen(),  // direct chat if needed
        '/home': (context) => const HomeShell(),   // home navigation wrapper
      },
    );
  }
}
