// ================= models/history_response.dart =================

class HistoryResponse {
  final bool success;
  final String message;
  final HistoryFilter filter;
  final int total;
  final List<HistoryItem> data;

  HistoryResponse({
    required this.success,
    required this.message,
    required this.filter,
    required this.total,
    required this.data,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    return HistoryResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      filter: HistoryFilter.fromJson(json["filter"] ?? {}),
      total: json["total"] ?? 0,
      data: List<HistoryItem>.from(
        (json["data"] ?? []).map(
          (x) => HistoryItem.fromJson(x),
        ),
      ),
    );
  }
}

class HistoryFilter {
  final String? search;
  final String? facility;
  final String? date;

  HistoryFilter({
    this.search,
    this.facility,
    this.date,
  });

  factory HistoryFilter.fromJson(Map<String, dynamic> json) {
    return HistoryFilter(
      search: json["search"],
      facility: json["facility"],
      date: json["date"],
    );
  }
}

class HistoryItem {
  final int id;
  final String hospitalName;
  final String facilityName;
  final String action;
  final String description;
  final String status;
  final String? createdAt;
  final String updatedBy;

  HistoryItem({
    required this.id,
    required this.hospitalName,
    required this.facilityName,
    required this.action,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedBy,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json["id"] ?? 0,
      hospitalName: json["hospital_name"] ?? "-",
      facilityName: json["facility_name"] ?? "-",
      action: json["action"] ?? "-",
      description: json["description"] ?? "-",
      status: json["status"] ?? "-",
      createdAt: json["created_at"],
      updatedBy: json["updated_by"] ?? "-",
    );
  }
}