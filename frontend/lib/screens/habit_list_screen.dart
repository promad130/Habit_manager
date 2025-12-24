import 'package:flutter/material.dart';
import 'package:frontend/widgets/habit_card.dart';
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
  Map<String, List<dynamic>> habitLogs = {};
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

      final fetchedHabits =
          data.map((e) => Habit.fromJson(e)).toList();

      final Map<String, List<dynamic>> logsMap = {};

      for (final habit in fetchedHabits) {
        final logs = await HabitService.getLogs(habit.id);
        logsMap[habit.id] = logs;
      }

      setState(() {
        habits = fetchedHabits;
        habitLogs = logsMap;
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDaily = selectedFrequency == 'daily';

          return Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment:
                      isDaily ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: width / 2,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _toggleItem("Daily", "daily"),
                    _toggleItem("Weekly", "weekly"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _toggleItem(String label, String value) {
    final selected = selectedFrequency == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedFrequency = value);
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.black : Colors.grey,
            ),
          ),
        ),
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
  bool isHabitCompleted(Habit habit) {
    final logs = habitLogs[habit.id] ?? [];

    if (logs.isEmpty) return false;

    final now = DateTime.now();

    if (habit.frequency == 'daily') {
      final todayStr = now.toIso8601String().split('T')[0];

      return logs.any(
        (log) =>
            log['date'] == todayStr &&
            log['completed'] == true,
      );
    }

    // weekly
    final weekAgo = now.subtract(const Duration(days: 7));

    return logs.any((log) {
      if (log['completed'] != true) return false;
      final logDate = DateTime.parse(log['date']);
      return logDate.isAfter(weekAgo);
    });
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
        centerTitle: true,
        title: const Text(
          "Habit Forge",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 18),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text("Logout"),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${filteredHabits.length} habits",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.filter_alt_outlined),
                            onSelected: (value) {
                              setState(() => selectedStatus = value);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'all', child: Text("All")),
                              PopupMenuItem(value: 'active', child: Text("Active")),
                              PopupMenuItem(value: 'archived', child: Text("Archived")),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: filteredHabits.isEmpty
                          ? const Center(
                              child: Text(
                                "No habits here yet 👀",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: filteredHabits.length,
                              itemBuilder: (context, index) {
                                final habit = filteredHabits[index];
                    
                                return HabitCard(
                                  habit: habit,
                                  isCompleted: isHabitCompleted(habit),
                                  onTap: () => _showHabitDialog(habit),
                                  onArchive: () => _toggleArchive(habit),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("New Habit"),
        onPressed: () {
          Navigator.pushNamed(context, '/add-habit')
              .then((_) => _loadHabits());
        },
      ),
    );
  }
}