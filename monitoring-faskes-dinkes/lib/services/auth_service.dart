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
      /// SIMPAN TOKEN
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", data['data']['token']);

      return true;
    }

    return false;
  }

  /// GET TOKEN
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("token");
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
