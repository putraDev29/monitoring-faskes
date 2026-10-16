import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constant.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("${ApiConstant.baseUrl}/login"),
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", data['data']['token']);

      // Simpan role & name dari response login
      await prefs.setString("role", data['data']['user']['role'] ?? '');
      await prefs.setString("name", data['data']['user']['name'] ?? '');
      await prefs.setInt("user_id", data['data']['user']['id'] ?? 0);

      return true;
    }

    return false;
  }

  /// GET TOKEN
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// GET ROLE USER YANG SEDANG LOGIN
  static Future<String> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("role") ?? '';
  }

  /// LOGOUT
  static Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/reset-password'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
