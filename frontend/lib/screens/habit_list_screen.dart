import 'package:flutter/material.dart';
import '../utils/sess_manager.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionManager.clearSession();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          )
        ],
      ),
      body: const Center(
        child: Text("Habit list will appear here"),
      ),
    );
  }
}