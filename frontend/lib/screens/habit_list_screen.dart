import 'package:flutter/material.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              //logout logic
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