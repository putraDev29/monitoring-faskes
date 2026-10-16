import 'export_service_io.dart'
    if (dart.library.html) 'export_service_web.dart';

class ExportService {
  static Future<void> downloadAndOpen({
    required String format,
    required String period,
    Map<String, dynamic>? extraParams,
    void Function(double progress)? onProgress,
  }) {
    return ExportServiceImpl.downloadAndOpen(
      format: format,
      period: period,
      extraParams: extraParams,
      onProgress: onProgress,
    );
  }
}