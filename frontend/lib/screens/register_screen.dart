import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/sess_manager.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userId = await AuthService.register(
        name: nameController.text.trim(),
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
          "Create Account",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Start building better habits today.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _registerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _nameField(),
            const SizedBox(height: 16),
            _emailField(),
            const SizedBox(height: 16),
            _passwordField(),
            const SizedBox(height: 24),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _nameField() {
    return TextField(
      controller: nameController,
      decoration: const InputDecoration(
        labelText: "Name",
        hintText: "Your name",
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

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _register,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Create Account",
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: const Text("Already have an account? Login"),
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
                    _registerCard(),
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