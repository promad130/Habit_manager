import 'package:flutter/material.dart';
import '../utils/sess_manager.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  bool isLoading = true;
  String? error;
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Future<void> _loadHabits() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final data = await HabitService.getHabits(userId: userId);

      setState(() {
        habits = data.map((e) => Habit.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : habits.isEmpty
                  ? const Center(child: Text("No habits yet"))
                  : ListView.builder(
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return ListTile(
                          title: Text(habit.title),
                          subtitle: Text(
                            "${habit.frequency} • ${habit.status}",
                          ),
                        );
                      },
                    ),
    );
  }
}