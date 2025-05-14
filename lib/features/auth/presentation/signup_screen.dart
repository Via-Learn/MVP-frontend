import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../application/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithGoogle();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/vialearnnew.png', height: 60),
              const SizedBox(height: 12),
              Image.asset(
                'assets/images/ViaLearn_Logo_Official.png',
                width: 260,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your AI-powered homepage for learning.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // ✨ Getting Started Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EBFF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Getting Started',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.black26, thickness: 1),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignUp,
                      icon: Image.asset('assets/images/google.png', width: 22, height: 22),
                      label: const Text('Sign up with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: const TextStyle(color: Colors.black54),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pushNamed(context, '/login'),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
