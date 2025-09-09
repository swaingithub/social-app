import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/providers/user_provider.dart';
import 'package:social_media_app/screens/login_screen.dart';
import 'package:social_media_app/screens/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.vertical,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcomeText(theme),
                  const SizedBox(height: 40),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return _buildCard(theme, userProvider);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildLoginLink(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.poppins(
            color: theme.primaryColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms).slideY(
              begin: 0.3,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 8),
        Text(
          'Start your journey with us',
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(
              begin: 0.3,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }

  Widget _buildCard(ThemeData theme, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUsernameField(theme),
          const SizedBox(height: 20),
          _buildEmailField(theme),
          const SizedBox(height: 20),
          _buildPasswordField(theme),
          const SizedBox(height: 24),
          _buildSignupButton(theme, userProvider),
        ],
      ),
    ).animate().scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: 600.ms,
        ).fadeIn(delay: 300.ms);
  }

  Widget _buildUsernameField(ThemeData theme) {
    return TextField(
      controller: _usernameController,
      style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
      decoration: _buildInputDecoration(
        labelText: 'Username',
        prefixIcon: Icons.person_outline,
        theme: theme,
      ),
      cursorColor: theme.primaryColor,
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextField(
      controller: _emailController,
      style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
      decoration: _buildInputDecoration(
        labelText: 'Email Address',
        prefixIcon: Icons.email_outlined,
        theme: theme,
      ),
      keyboardType: TextInputType.emailAddress,
      cursorColor: theme.primaryColor,
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return TextField(
      controller: _passwordController,
      style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
      decoration: _buildInputDecoration(
        labelText: 'Password',
        prefixIcon: Icons.lock_outline_rounded,
        theme: theme,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      cursorColor: theme.primaryColor,
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    required ThemeData theme,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(prefixIcon, color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  Widget _buildSignupButton(ThemeData theme, UserProvider userProvider) {
    return ElevatedButton(
      onPressed: userProvider.isLoading
          ? null
          : () async {
              if (_usernameController.text.isEmpty ||
                  _emailController.text.isEmpty ||
                  _passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              try {
                await userProvider.register(
                  _usernameController.text.trim(),
                  _emailController.text.trim(),
                  _passwordController.text,
                );
                
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 5,
        shadowColor: theme.primaryColor.withOpacity(0.4),
      ),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return userProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
        },
      ),
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.black54),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            'Sign In',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }
}