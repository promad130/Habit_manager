// lib/widgets/habit_card.dart
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../themes/app_text.dart';
import '../themes/app_colors.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final bool isCompleted;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onArchive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isCompleted
          ? Colors.green.withValues(alpha: 0.08)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : habit.status == 'archived'
                          ? Colors.grey
                          : Colors.indigo,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.frequency.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  habit.status == 'archived'
                      ? Icons.unarchive
                      : Icons.archive,
                ),
                onPressed: onArchive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}