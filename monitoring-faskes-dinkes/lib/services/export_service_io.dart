import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/api_constant.dart';
import 'auth_service.dart';

class ExportServiceImpl {
  static Future<void> downloadAndOpen({
    required String format,
    required String period,
    Map<String, dynamic>? extraParams,
    void Function(double progress)? onProgress,
  }) async {
    final token = await AuthService.getToken();

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstant.baseUrl,
        headers: {
          'Accept': 'application/json',
          if (token != null)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    final ext = switch (format) {
      'excel' => 'xlsx',
      'csv' => 'csv',
      _ => 'pdf',
    };

    final dir = await getTemporaryDirectory();

    final path =
        '${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await dio.download(
      '/dinkes/reports/export/$format',
      path,
      queryParameters: {
        'period': period,
        ...?extraParams,
      },
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress?.call(received / total);
        }
      },
    );

    final result = await OpenFilex.open(path);

    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }
}