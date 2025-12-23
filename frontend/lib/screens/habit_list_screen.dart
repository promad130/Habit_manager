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
  String selectedStatus = 'all';

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

  Future<void> _toggleArchive(Habit habit) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception("Not logged in");

      final newStatus =
          habit.status == 'active' ? 'archived' : 'active';

      await HabitService.updateHabit(
        habitId: habit.id,
        userId: userId,
        updates: {
          'status': newStatus,
        },
      );

      await _loadHabits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHabits = habits.where((habit) {
      final matchesFrequency = habit.frequency == selectedFrequency;

      final matchesStatus = selectedStatus == 'all'
          ? true
          : habit.status == selectedStatus;

      return matchesFrequency && matchesStatus;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStatus,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: const [
                DropdownMenuItem(value: 'all', child: Text("All")),
                DropdownMenuItem(value: 'active', child: Text("Active")),
                DropdownMenuItem(value: 'archived', child: Text("Archived")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ),
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
                                  title: Text(
                                    habit.title,
                                    style: TextStyle(
                                      decoration: habit.status == 'archived'
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Text("${habit.frequency} • ${habit.status}"),
                                  trailing: IconButton(
                                    icon: Icon(
                                      habit.status == 'archived'
                                          ? Icons.unarchive
                                          : Icons.archive,
                                    ),
                                    onPressed: () => _toggleArchive(habit),
                                  ),
                                  onTap: () {
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