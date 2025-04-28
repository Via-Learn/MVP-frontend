import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../core/constants/app_theme.dart';
import '../application/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleEmailLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.loginWithEmail(_emailController.text, _passwordController.text);
      if (user != null) {
        await _authService.verifyUserSession(user);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.loginWithGoogle();
      if (user != null) {
        await _authService.verifyUserSession(user);
        Navigator.pushReplacementNamed(context, '/home');
      }
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
                    const Text('Welcome Back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      icon: Image.asset('assets/images/google.png', width: 20, height: 20),
                      label: const Text('Login with Google'),
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
                      onPressed: _isLoading ? null : _handleEmailLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: AppColors.primary)
                          : const Text('Login'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'Don’t have an account? ',
                        style: const TextStyle(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.pushNamed(context, '/signup');
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
