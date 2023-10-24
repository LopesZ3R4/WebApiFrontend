// lib/services/clientservice.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/client.dart';

class ClientService {
  //final String _baseUrl = 'http://10.66.181.93:8000';
  final String _baseUrl = 'http://localhost:80';
  Future<List<Client>> getClients(String token) async {
    try {
      var url = '$_baseUrl/Clients/GetClients';

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        List<Client> clients =
            data.map((item) => Client.fromJson(item)).toList();
        return clients;
      } else {
        throw Exception(
            'Failed to fetch clients, status code: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }
}
