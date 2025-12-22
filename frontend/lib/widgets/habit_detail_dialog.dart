import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../utils/sess_manager.dart';

class HabitDetailDialog extends StatefulWidget {
  final Habit habit;
  final VoidCallback onActionComplete;

  const HabitDetailDialog({
    super.key,
    required this.habit,
    required this.onActionComplete,
  });

  @override
  State<HabitDetailDialog> createState() => _HabitDetailDialogState();
}

class _HabitDetailDialogState extends State<HabitDetailDialog> {
  bool isLoading = false;
  String? error;

  Future<void> _markTodayDone() async {
    setState(() => isLoading = true);

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("Not logged in");

      final today = DateTime.now().toIso8601String().split('T')[0];

      await HabitService.markHabit(
        habitId: widget.habit.id,
        date: today,
        userId: userId,
      );

      widget.onActionComplete();

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marked as done for today")),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteHabit() async {
    setState(() => isLoading = true);

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("Not logged in");

      await HabitService.deleteHabit(
        habitId: widget.habit.id,
        userId: userId,
      );

      widget.onActionComplete();

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
    return AlertDialog(
      title: Text(widget.habit.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.habit.description.isEmpty
                ? "No description"
                : widget.habit.description,
          ),
          const SizedBox(height: 12),
          Text(
            "Frequency: ${widget.habit.frequency}",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: isLoading ? null : _deleteHabit,
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _markTodayDone,
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Mark Done"),
        ),
      ],
    );
  }
}