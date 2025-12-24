import 'package:flutter/material.dart';
import 'package:frontend/themes/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/habit_list_screen.dart';
import 'screens/add_habit_screen.dart';
import 'models/habit.dart';

void main() {
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Habit Tracker',
      theme: AppTheme.light(),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/habits': (_) => const HabitListScreen(),
        '/add-habit': (context) {
          final habit = ModalRoute.of(context)?.settings.arguments as Habit?;
          return AddHabitScreen(habit: habit);
        },
      },
    );
  }
}