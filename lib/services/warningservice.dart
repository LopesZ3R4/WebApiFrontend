// lib/services/warningservice.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/warning.dart';

class WarningService {
  //final String _baseUrl = 'http://172.28.208.1:8000';
  final String _baseUrl = 'http://localhost:80';
  Future<Map<String, dynamic>> getWarnings(String token,
      {int pageNumber = 1,
      int pageSize = 10,
      String? type,
      String? color,
      String? severity,
      DateTime? date,
      String? machineType,
      int? clientid}) async {
    try {
      var url =
          '$_baseUrl/Alert/GetAlerts?pageNumber=$pageNumber&pageSize=$pageSize';
      if (type != null) {
        url += '&type=$type';
      }
      if (color != null) {
        url += '&color=$color';
      }
      if (severity != null) {
        url += '&severity=$severity';
      }
      if (date != null) {
        url += '&date=${date.toIso8601String()}';
      }
      if (machineType != null) {
        url += '&machineType=$machineType';
      }
      if (clientid != null) {
        url += '&clientid=$clientid';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<Warning> warnings = (data['alerts'] as List)
            .map<Warning>((item) => Warning.fromJson(item))
            .toList();
        return {
          'count': data['count'],
          'hasMore': data['hasMore'],
          'warnings': warnings,
        };
      } else {
        throw Exception(
            'Failed to fetch warnings, status code: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }
}
