
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final bool isTest;
  const LoginScreen({super.key, required this.auth, this.isTest = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // To toggle between Login and Sign Up

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await widget.auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await widget.auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Authentication failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _skipLogin() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          if (!widget.isTest)
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Overlay
          if (!widget.isTest)
            Container(
              color: Colors.black.withOpacity(0.6),
            ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Title
                  Text(
                    'SocialApp',
                    style: widget.isTest
                        ? theme.textTheme.displayLarge
                        : theme.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              const Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(5.0, 5.0),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 48),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: widget.isTest
                        ? null
                        : BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: widget.isTest
                              ? null
                              : const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: widget.isTest
                                ? null
                                : TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.email_outlined,
                                color: theme.colorScheme.primary),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: widget.isTest
                                      ? Colors.grey
                                      : Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: widget.isTest
                              ? null
                              : const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: widget.isTest
                                ? null
                                : TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.lock_outline,
                                color: theme.colorScheme.primary),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: widget.isTest
                                      ? Colors.grey
                                      : Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: Text(_isLogin ? 'Login' : 'Sign Up'),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Toggle Form TextButton
                        TextButton(
                          onPressed: _toggleForm,
                          child: Text(
                            _isLogin
                                ? 'Don\'t have an account? Sign Up'
                                : 'Already have an account? Login',
                            style: widget.isTest
                                ? null
                                : TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Skip Button
                  TextButton(
                    onPressed: _skipLogin,
                    child: Text(
                      'Skip for now',
                      style: widget.isTest
                          ? null
                          : TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
