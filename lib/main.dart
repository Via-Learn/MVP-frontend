import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/firebase_options.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';

import 'features/auth/presentation/explore_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'navigation/home_shell.dart';

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
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ViaLearn Flutter',
            theme: AppTheme.lightTheme,               // ✅ default light
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,       // ✅ dynamic
            debugShowCheckedModeBanner: false,
            home: const ExploreScreen(),
            routes: {
              '/signup': (context) => const SignupScreen(),
              '/login': (context) => const LoginScreen(),
              '/chat': (context) => const ChatScreen(),
              '/home': (context) => const HomeShell(),
            },
          );
        },
      ),
    );
  }
}
