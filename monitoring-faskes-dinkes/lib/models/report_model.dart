// models/report_model.dart

class ReportModel {
  final bool success;
  final String message;
  final String period;
  final ReportData data;

  ReportModel({
    required this.success,
    required this.message,
    required this.period,
    required this.data,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      period: json['period'] ?? '',
      data: ReportData.fromJson(json['data']),
    );
  }
}

class ReportData {
  final Summary summary;
  final List<GraphData> graph;
  final ExportData export;

  ReportData({
    required this.summary,
    required this.graph,
    required this.export,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      summary: Summary.fromJson(json['summary'] ?? {}),
      graph: List<GraphData>.from(
        (json['graph'] ?? []).map((x) => GraphData.fromJson(x)),
      ),
      export: ExportData.fromJson(json['export'] ?? {}),
    );
  }
}

class Summary {
  final int totalHospital;
  final int totalFacility;
  final double averagePercentage;

  Summary({
    required this.totalHospital,
    required this.totalFacility,
    required this.averagePercentage,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalHospital: json['total_hospital'] ?? 0,
      totalFacility: json['total_facility'] ?? 0,
      averagePercentage:
          double.tryParse(json['average_percentage'].toString()) ?? 0.0,
    );
  }
}

class GraphData {
  final String date;
  final double percentage;

  GraphData({required this.date, required this.percentage});

  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      date: json['date']?.toString() ?? '',
      percentage: double.tryParse(json['percentage'].toString()) ?? 0.0,
    );
  }
}

class ExportData {
  final String pdf;
  final String excel;
  final String csv;

  ExportData({required this.pdf, required this.excel, required this.csv});

  factory ExportData.fromJson(Map<String, dynamic> json) {
    return ExportData(
      pdf: json['pdf'] ?? '',
      excel: json['excel'] ?? '',
      csv: json['csv'] ?? '',
    );
  }
}
