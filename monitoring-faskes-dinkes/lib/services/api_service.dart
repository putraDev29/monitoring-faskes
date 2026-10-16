import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monitoring_faskes_dinkes/models/facility_model.dart';
import 'package:monitoring_faskes_dinkes/models/history_model.dart';
import 'package:monitoring_faskes_dinkes/models/hospital_model.dart';
import 'package:monitoring_faskes_dinkes/models/notification_model.dart';
import 'package:monitoring_faskes_dinkes/models/profile_model.dart';
import 'package:monitoring_faskes_dinkes/models/report_model.dart';
import 'package:monitoring_faskes_dinkes/models/examination_model.dart';
import '../models/dashboard_model.dart';
import '../utils/api_constant.dart';
import 'package:logger/logger.dart';
import 'auth_service.dart';

class ApiService {
  static Future<DashboardModel> getDashboard() async {
    /// AMBIL TOKEN
    String? token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConstant.baseUrl}/dinkes/dashboard"),

      headers: {
        "Accept": "application/json",

        /// BEARER TOKEN
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    return DashboardModel.fromJson(data);
  }

  static Future<List<HospitalData>> getHospitals() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConstant.baseUrl}/dinkes/hospitals"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final result = HospitalModels.fromJson(data);

        return result.data;
      } else {
        throw Exception("Gagal mengambil data rumah sakit");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<DetailHospitalModel> getDetailHospital(int id) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConstant.baseUrl}/dinkes/hospitals/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      return DetailHospitalModel.fromJson(data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Facility>> getFacilities(
    int hospitalId, {
    String? status,
  }) async {
    try {
      String? token = await AuthService.getToken();

      final uri = Uri.parse(
        "${ApiConstant.baseUrl}/dinkes/hospitals/$hospitalId/facilities",
      ).replace(queryParameters: status != null ? {'status': status} : null);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat data fasilitas');
      }

      final data = jsonDecode(response.body);

      final result = FacilityResponse.fromJson(data);
      print(result);

      return result.data;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // services/api_service.dart

  static Future<DetailFacilityData> getDetailFacility({
    required int hospitalId,
    required int facilityId,
  }) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse(
          "${ApiConstant.baseUrl}/dinkes/hospitals/$hospitalId/facilities/$facilityId",
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final result = DetailFacilityModel.fromJson(data);

        return result.data;
      } else {
        throw Exception("Gagal mengambil detail fasilitas");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static final Logger logger = Logger();

  static Future<ReportModel> getReport({String period = '7days'}) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConstant.baseUrl}/dinkes/reports?period=$period"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      logger.i("STATUS : ${response.statusCode}");
      logger.i("BODY : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return ReportModel.fromJson(data);
      }

      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    } catch (e) {
      logger.e("GET REPORT ERROR", error: e);
      throw Exception(e.toString());
    }
  }

  static Future<List<HistoryItem>> getHistory({String? facility}) async {
    try {
      String? token = await AuthService.getToken();
      Uri uri = Uri.parse("${ApiConstant.baseUrl}/dinkes/histories");

      // QUERY PARAM
      uri = uri.replace(
        queryParameters: {
          if (facility != null &&
              facility.isNotEmpty &&
              facility != "Semua Fasilitas")
            "facility": facility,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = HistoryResponse.fromJson(jsonDecode(response.body));

        return data.data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<ProfileModel?> getProfile() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConstant.baseUrl}/dinkes/profile"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return ProfileModel.fromJson(json);
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
        Uri.parse("${ApiConstant.baseUrl}/dinkes/notifications"),
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
        Uri.parse('${ApiConstant.baseUrl}/dinkes/notifications/$id/read'),
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
        Uri.parse('${ApiConstant.baseUrl}/dinkes/notifications/unread/count'),
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

  static Future<List<Examination>> getHospitalExaminations(int id) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/dinkes/hospitals/$id/examinations'),
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
        Uri.parse('${ApiConstant.baseUrl}dinkes/examinations'),
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
        Uri.parse('${ApiConstant.baseUrl}/dinkes/examinations/$id'),
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

  static Future<List<User>> getDinkesUsers() async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/dinkes/users'),
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
            .where((u) => u.role == 'dinkes')
            .toList();
      } else {
        throw Exception('Gagal memuat daftar dinkes: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── POST /register ─────────────────────────────────────────────────────────
  /// Tambah user baru dengan role admin (khusus admin_utama)
  static Future<Map<String, dynamic>> createDinkesUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      String? token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/dinkes/register'),
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
          'role': 'dinkes',
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"statusCode": response.statusCode, "data": body};
      } else {
        // Tangkap pesan error dari backend (misal validasi duplikat email)
        final message = body['message'] ?? 'Gagal menambahkan dinkes';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateDinkesUser({
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
        Uri.parse('${ApiConstant.baseUrl}/dinkes/users/$id'),
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

  static Future<Map<String, dynamic>> deleteDinkesUser(int id) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.delete(
        Uri.parse('${ApiConstant.baseUrl}/dinkes/users/$id'),
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
