// login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../application/auth_service.dart';
import '../../../core/widgets/gradient_background.dart';

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
      final user = await _authService.loginWithEmail(
        _emailController.text, _passwordController.text);
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
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(height: 10),
                Image.asset('assets/images/vialearn.png', height: 60),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Welcome Back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _isLoading ? null : _handleGoogleLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/google.png', width: 20, height: 20),
                              const SizedBox(width: 8),
                              const Text('Login with Google', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      const Text('Or'),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          fixedSize: const Size(120, 50),
                        ),
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          text: 'Don’t have an account? ',
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: const TextStyle(color: Color(0xFF4C67F7), fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
