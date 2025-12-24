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
        await HabitService.createHabit(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          frequency: frequency,
          owner: userId,
        );
      } else {
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

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.habit == null
              ? "Create a new habit"
              : "Update your habit",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.habit == null
              ? "Small actions, big consistency."
              : "Refine it, don’t restart it.",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _formCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _titleField(),
            const SizedBox(height: 16),
            _descriptionField(),
            const SizedBox(height: 20),
            _frequencySelector(),
          ],
        ),
      ),
    );
  }

  Widget _titleField() {
    return TextField(
      controller: titleController,
      decoration: const InputDecoration(
        labelText: "Habit Title",
        hintText: "e.g. Read 20 minutes",
      ),
    );
  }

  Widget _descriptionField() {
    return TextField(
      controller: descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: "Description (optional)",
        hintText: "Why this habit matters to you",
      ),
    );
  }

  Widget _frequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Frequency",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _freqChip("Daily"),
            const SizedBox(width: 8),
            _freqChip("Weekly"),
          ],
        ),
      ],
    );
  }

  Widget _freqChip(String label) {
    final value = label.toLowerCase();
    final selected = frequency == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => frequency = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.indigo : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitHabit,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.habit == null ? "Create Habit" : "Save Changes",
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.habit == null ? "New Habit" : "Edit Habit",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              _formCard(),
              const SizedBox(height: 32),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }
}