// lib/services/warningservice.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/warning.dart';

class WarningService {
  final String _baseUrl = 'http://192.168.0.243:8000';

  Future<Map<String, dynamic>> getWarnings(String token, {int pageNumber = 1, int pageSize = 1, String? type, String? color, String? severity, DateTime? date}) async {
    try {
      final response = await http.get(
        //Uri.parse('$_baseUrl/GetAlerts?pageNumber=$pageNumber&pageSize=$pageSize&type=$type&color=$color&severity=$severity&date=${date?.toIso8601String()}'),
        Uri.parse('$_baseUrl/Alert/GetAlerts?pageNumber=$pageNumber&pageSize=$pageSize'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<Warning> warnings = (data['alerts'] as List).map<Warning>((item) => Warning.fromJson(item)).toList();
        return {
          'count': data['count'],
          'hasMore': data['hasMore'],
          'warnings': warnings,
        };
      } else {
        throw Exception('Failed to fetch warnings, status code: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }
}