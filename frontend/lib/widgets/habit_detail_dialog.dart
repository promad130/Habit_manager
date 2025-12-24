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
  List<dynamic> logs = [];
  Map<String, dynamic>? stats;
  bool loadingDetails = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final fetchedLogs =
          await HabitService.getLogs(widget.habit.id);
      final fetchedStats =
          await HabitService.getStats(widget.habit.id);

      setState(() {
        logs = fetchedLogs;
        stats = fetchedStats;
        loadingDetails = false;
      });
    } catch (_) {
      setState(() {
        loadingDetails = false;
      });
    }
  }

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
      await _loadDetails();

      widget.onActionComplete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marked as done for today")),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> _unmarkToday() async {
    setState(() => isLoading = true);

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("Not logged in");

      final today = DateTime.now().toIso8601String().split('T')[0];

      await HabitService.markHabit(
        habitId: widget.habit.id,
        date: today,
        userId: userId,
        completed: false,
      );

      await _loadDetails();
      widget.onActionComplete();
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

  void _editHabit() {
    Navigator.pop(context);

    Navigator.pushNamed(
      context,
      '/add-habit',
      arguments: widget.habit,
    ).then((_) {
      widget.onActionComplete();
    });
  }

  bool get isDoneToday {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return logs.any(
      (log) => log['date'] == today && log['completed'] == true,
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.habit.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.habit.description.isEmpty
              ? "No description"
              : widget.habit.description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.habit.frequency.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _completionToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Completed Today",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: isDoneToday,
            onChanged: isLoading
                ? null
                : (value) {
                    value ? _markTodayDone() : _unmarkToday();
                  },
          ),
        ],
      ),
    );
  }

  Widget _statsSection() {
    if (loadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stats == null) {
      return const Text("No stats available");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Progress",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statItem("Rate", "${stats!['completionRate']}%"),
            _statItem(
              "Days",
              "${stats!['daysCompleted']} / ${stats!['totalDaysTracked']}",
            ),
          ],
        ),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _logsSection() {
    if (loadingDetails) return const SizedBox();

    if (logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text(
          "No activity yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Recent Activity",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 120,
          child: ListView.builder(
            itemCount: logs.length > 5 ? 5 : logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log['date'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    Icon(
                      log['completed']
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: log['completed']
                          ? Colors.green
                          : Colors.red,
                      size: 18,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _editHabit,
          icon: const Icon(Icons.edit),
          label: const Text("Edit"),
        ),
        TextButton(
          onPressed: _deleteHabit,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text("Delete"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _completionToggle(),
            const SizedBox(height: 20),
            _statsSection(),
            _logsSection(),
            const SizedBox(height: 20),
            _actions(),
          ],
        ),
      ),
    );
  }
}