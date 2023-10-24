// lib/services/machineservice.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class MachineService {
  //final String _baseUrl = 'http://10.66.181.93:8000';
  final String _baseUrl = 'http://localhost:8000';
  Future<List<String>> fetchIconNames(String token) async {
    try {
      var url = '$_baseUrl/Machine/GetMachines/Types';

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<String> machines = data;
        return machines;
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
