import 'package:flutter/material.dart';
import '../services/habit_service.dart';
import '../utils/sess_manager.dart';
import '../models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habit;
  const AddHabitScreen({super.key,this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String frequency = 'daily';
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      titleController.text = widget.habit!.title;
      descriptionController.text = widget.habit!.description;
      frequency = widget.habit!.frequency;
    }
  }

  Future<void> _submitHabit() async {
    if (titleController.text.trim().isEmpty) {
      setState(() => error = "Title is required");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("Not logged in");

      if (widget.habit == null) {
        // CREATE
        await HabitService.createHabit(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          frequency: frequency,
          owner: userId,
        );
      } else {
        // UPDATE
        await HabitService.updateHabit(
          habitId: widget.habit!.id,
          userId: userId,
          updates: {
            'title': titleController.text.trim(),
            'description': descriptionController.text.trim(),
            'frequency': frequency,
          },
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
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
                    onPressed: isLoading ? null : _submitHabit,
                    child: Text(widget.habit == null ? "Create Habit" : "Save Changes"),
                  ),
          ],
        ),
      ),
    );
  }
}