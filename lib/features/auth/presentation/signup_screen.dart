import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../core/constants/app_theme.dart';
import '../application/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleEmailSignUp() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmail(_emailController.text, _passwordController.text);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/logo.png', height: 60),
              const SizedBox(height: 10),
              Image.asset('assets/images/vialearn.png', width: 250, height: 50, fit: BoxFit.contain),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('Getting Started', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignUp,
                      icon: Image.asset('assets/images/google.png', width: 20, height: 20),
                      label: const Text('Sign up with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('OR', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: 'Email'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Password'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailSignUp,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: AppColors.primary)
                          : const Text('Sign Up'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: const TextStyle(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.pushNamed(context, '/login');
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
