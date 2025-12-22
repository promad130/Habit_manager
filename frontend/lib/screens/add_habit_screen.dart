import 'package:flutter/material.dart';
import '../services/habit_service.dart';
import '../utils/sess_manager.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String frequency = 'daily';
  bool isLoading = false;
  String? error;

  Future<void> _createHabit() async {
    if (titleController.text.trim().isEmpty) {
      setState(() {
        error = "Title is required";
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("Not logged in");

      await HabitService.createHabit(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        frequency: frequency,
        owner: userId,
      );

      if (!mounted) return;
      Navigator.pop(context); // go back to habit list
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Habit")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: frequency,
              items: const [
                DropdownMenuItem(value: 'daily', child: Text("Daily")),
                DropdownMenuItem(value: 'weekly', child: Text("Weekly")),
              ],
              onChanged: (value) {
                setState(() {
                  frequency = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Frequency"),
            ),

            const SizedBox(height: 24),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createHabit,
                    child: const Text("Create Habit"),
                  ),
          ],
        ),
      ),
    );
  }
}