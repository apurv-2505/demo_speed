import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_call.dart';

class ApiService {
  static const String serverUrl = 'http://localhost:3000';

  static Future<void> executeApiCall(ApiCall apiCall) async {
    final response = await http.post(
      Uri.parse('$serverUrl/data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'data': apiCall.data}),
    );

    if (response.statusCode != 201) {
      throw Exception('API call failed with status: ${response.statusCode}');
    }
  }
}
