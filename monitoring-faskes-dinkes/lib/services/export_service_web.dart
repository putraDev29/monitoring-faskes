import 'dart:html' as html;
import 'dart:typed_data';

import 'package:dio/dio.dart';

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
          'Accept': 'application/octet-stream',
          if (token != null)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    final response = await dio.get<List<dynamic>>(
      '/dinkes/reports/export/$format',
      queryParameters: {
        'period': period,
        ...?extraParams,
      },
      options: Options(
        responseType: ResponseType.bytes,
      ),
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress?.call(received / total);
        }
      },
    );

    final bytes = Uint8List.fromList(
      List<int>.from(response.data ?? []),
    );

    final blob = html.Blob([bytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);

    final ext = switch (format) {
      'excel' => 'xlsx',
      'csv' => 'csv',
      _ => 'pdf',
    };

    final anchor = html.AnchorElement(href: url)
      ..download =
          'laporan_${DateTime.now().millisecondsSinceEpoch}.$ext';

    anchor.click();

    html.Url.revokeObjectUrl(url);
  }
}