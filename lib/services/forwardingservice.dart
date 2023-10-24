// lib/services/forwardingservice.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../model/warning.dart';

class ForwardingService {
  Future<void> sendWarnings(String token, List<Warning> warnings) async {
    //String baseUrl = 'http://10.66.181.93:8000';
    String baseUrl = 'http://localhost:80';
    String url = '$baseUrl/Encaminhamento';

    for (var warning in warnings) {
      if (warning.selected) {
        var body = jsonEncode({
          'AlertId': warning.id,
          'Motivo': warning.definitionType,
          'IdEmpresa': warning.clientId,
        });

        var response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        if (response.statusCode != 200) {
          throw Exception(
              'Failed to send warning, status code: ${response.statusCode}, body: ${response.body}');
        } else {
          warning.sent = true;
        }
      }
    }
  }
}
