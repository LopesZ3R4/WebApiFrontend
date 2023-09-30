// lib/services/authservice.dart

import "package:http/http.dart" as http;
import 'dart:convert';

class AuthService {
  final String _baseUrl = 'http://192.168.1.232:8000';

  Future<String> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      ).timeout(Duration(seconds: 10));
      print("Trying to login with username: $username");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String jwtToken = data['token'];
        print('sucessfully authenticated');
        return jwtToken;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      print('An error occurred in login: $e'); 
      throw e;
    }
  }
}