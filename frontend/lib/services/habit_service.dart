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
}