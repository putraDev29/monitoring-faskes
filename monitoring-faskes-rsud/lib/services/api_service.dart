import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monitoring_faskes_rsud/models/facility_model.dart';
import 'package:monitoring_faskes_rsud/models/input_facility_model.dart';
import 'package:monitoring_faskes_rsud/models/notification_model.dart';
import 'package:monitoring_faskes_rsud/models/profile_model.dart';
import '../models/dashboard_model.dart';
import '../models/hospital_model.dart';
import '../models/examination_model.dart';
import '../utils/api_constant.dart';
import 'auth_service.dart';

class ApiService {
  static Future<DashboardModel> getDashboard() async {
    String? token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConstant.baseUrl}/dashboard"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);

    return DashboardModel.fromJson(data);
  }

  static Future<List<Facility>> getFacilities() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConstant.baseUrl}/facilities"),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      final result = FacilityResponse.fromJson(data);

      return result.data;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> storeFacility(
    InputFacilityModel data,
  ) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse("${ApiConstant.baseUrl}/facilities"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data.toJson()),
      );

      return {
        "statusCode": response.statusCode,
        "data": jsonDecode(response.body),
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateFacility(
    int id,
    EditFacilityModel data,
  ) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.put(
        Uri.parse("${ApiConstant.baseUrl}/facilities/$id"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data.toJson()),
      );

      return {
        "statusCode": response.statusCode,
        "data": jsonDecode(response.body),
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<HistoryFacility>> getHistory() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConstant.baseUrl}/histories"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        HistoryFacilityResponse result = HistoryFacilityResponse.fromJson(
          jsonData,
        );

        return result.data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<ProfileResponse?> getProfile() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConstant.baseUrl}/profile"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return ProfileResponse.fromJson(json);
      } else {
        throw Exception(
          'Gagal mengambil profile. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil profile: $e');
    }
  }

  static Future<List<NotificationModel>> getNotifications(String filter) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConstant.baseUrl}/notifications"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      final List list = data['data'];

      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<void> readNotification(int id) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/notifications/$id/read'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal update notifikasi');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/notifications/unread/count'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      return data['count'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<HospitalList>> getHospitals({String? search}) async {
    try {
      String? token = await AuthService.getToken();

      final uri = Uri.parse('${ApiConstant.baseUrl}/hospitals').replace(
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
      );

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return (body['data'] as List<dynamic>)
            .map((e) => HospitalList.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat daftar rumah sakit: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<HospitalDetail> getHospitalDetail(int id) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/hospitals/$id'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return HospitalDetail.fromJson(body['data']);
      } else {
        throw Exception('Rumah sakit tidak ditemukan');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Examination>> getHospitalExaminations(int id) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/hospitals/$id/examinations'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return (body['data'] as List<dynamic>)
            .map((e) => Examination.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Gagal memuat pemeriksaan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Examination>> getExaminations() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/examinations'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return (body['data'] as List<dynamic>)
            .map((e) => Examination.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat data pemeriksaan: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Examination> getExamination(int id) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/examinations/$id'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return Examination.fromJson(body['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Pemeriksaan tidak ditemukan');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Examination> createExamination({
    required String examinationName,
    required String doctorName,
    required String openingHours,
    required String closingHours,
  }) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/examinations'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'examination_name': examinationName,
          'doctor_name': doctorName,
          'opening_hours': openingHours,
          'closing_hours': closingHours,
        }),
      );

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return Examination.fromJson(body['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Gagal menambah pemeriksaan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Examination> updateExamination({
    required int id,
    required String examinationName,
    required String doctorName,
    required String openingHours,
    required String closingHours,
  }) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.put(
        Uri.parse('${ApiConstant.baseUrl}/examinations/$id'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'examination_name': examinationName,
          'doctor_name': doctorName,
          'opening_hours': openingHours,
          'closing_hours': closingHours,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return Examination.fromJson(body['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Gagal memperbarui pemeriksaan: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteExamination(int id) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.delete(
        Uri.parse('${ApiConstant.baseUrl}/examinations/$id'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus pemeriksaan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── GET /users ─────────────────────────────────────────────────────────────
  /// Ambil list semua user dengan role admin (khusus admin_utama)
  static Future<List<User>> getAdminUsers() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/users'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Ambil list dari key 'data', filter hanya role 'admin'
        final List list = body['data'] as List;

        return list
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .where((u) => u.role == 'admin')
            .toList();
      } else {
        throw Exception('Gagal memuat daftar admin: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── POST /register ─────────────────────────────────────────────────────────
  /// Tambah user baru dengan role admin (khusus admin_utama)
  static Future<Map<String, dynamic>> createAdminUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/register'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone_number': phoneNumber,
          'address': address,
          'role': 'admin',
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"statusCode": response.statusCode, "data": body};
      } else {
        // Tangkap pesan error dari backend (misal validasi duplikat email)
        final message = body['message'] ?? 'Gagal menambahkan admin';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateAdminUser({
    required int id,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    String? password,
  }) async {
    try {
      final token = await AuthService.getToken();

      final body = {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
      };

      if (password != null && password.trim().isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
        Uri.parse('${ApiConstant.baseUrl}/users/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ================= DELETE USER =================

  static Future<Map<String, dynamic>> deleteAdminUser(int id) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.delete(
        Uri.parse('${ApiConstant.baseUrl}/users/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
