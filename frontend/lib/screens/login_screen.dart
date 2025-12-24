import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/sess_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? error;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userId = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await SessionManager.saveUserId(userId);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/habits',
        (route) => false,
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          "Habit Forge",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          "Build consistency, one habit at a time.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _loginCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _emailField(),
            const SizedBox(height: 16),
            _passwordField(),
            const SizedBox(height: 24),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email",
        hintText: "you@example.com",
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Password",
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Login",
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/register');
        },
        child: const Text("Don’t have an account? Create one"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),
                    Center(child: _header()),
                    const SizedBox(height: 32),
                    _loginCard(),
                    const SizedBox(height: 24),
                    _footer(context),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}