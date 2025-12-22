import 'package:flutter/material.dart';
import '../utils/sess_manager.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/habit_detail_dialog.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  bool isLoading = true;
  String? error;
  List<Habit> habits = [];
  String _formattedToday() {
    final now = DateTime.now();
    const days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday'
    ];
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
  
    return "${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}";
  }
  String selectedFrequency = 'daily';

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
  void _showHabitDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return HabitDetailDialog(
          habit: habit,
          onActionComplete: _loadHabits,
        );
      },
    );
  }

  Widget _frequencyToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Text("Daily"),
              selected: selectedFrequency == 'daily',
              onSelected: (_) {
                setState(() {
                  selectedFrequency = 'daily';
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: const Text("Weekly"),
              selected: selectedFrequency == 'weekly',
              onSelected: (_) {
                setState(() {
                  selectedFrequency = 'weekly';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredHabits = habits
    .where((h) => h.frequency == selectedFrequency)
    .toList();
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
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _formattedToday(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _frequencyToggle(),

                    const SizedBox(height: 12),

                    Expanded(
                      child: filteredHabits.isEmpty
                          ? const Center(
                              child: Text("No habits for this frequency"),
                            )
                          : ListView.builder(
                              itemCount: filteredHabits.length,
                              itemBuilder: (context, index) {
                                final habit = filteredHabits[index];
                                return ListTile(
                                  title: Text(habit.title),
                                  subtitle: Text(
                                    "${habit.frequency} • ${habit.status}",
                                  ),
                                  onTap:() {
                                    _showHabitDialog(habit);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-habit')
              .then((_) => _loadHabits());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}