import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiDomain = "http://172.20.10.10:3002/";

  static Future<dynamic> get(String path) async {
    final response = await http.get(Uri.parse(apiDomain + path));
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(apiDomain + path),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> del(String path) async {
    final response = await http.delete(Uri.parse(apiDomain + path));
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse(apiDomain + path),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Lỗi kết nối: ${response.statusCode}");
    }
  }
}