import 'dart:convert';
import 'package:http/http.dart' as http;

class HabitService {
  static const String baseUrl = 'http://192.168.29.113:5000/api/habits';

  static Future<List<dynamic>> getHabits({
    required String userId,
    String? status,
  }) async {
    final uri = Uri.parse(
      status == null
          ? '$baseUrl/$userId'
          : '$baseUrl/$userId?status=$status',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load habits');
    }
  }

  static Future<void> createHabit({
    required String title,
    required String description,
    required String frequency,
    required String owner,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'frequency': frequency,
        'owner': owner,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to create habit');
    }
  }
  static Future<void> markHabit({
    required String habitId,
    required String date,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$habitId/mark'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'date': date,
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to mark habit');
    }
  }
  static Future<void> deleteHabit({
    required String habitId,
    required String userId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$habitId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
      }),
    );
  
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete habit');
    }
  }
}