class DashboardModel {
  final Hospital hospital;
  final Summary summary;
  final List<AlertModel> alerts;

  DashboardModel({
    required this.hospital,
    required this.summary,
    required this.alerts,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return DashboardModel(
      hospital: Hospital.fromJson(data['hospital'] ?? {}),

      summary: Summary.fromJson(data['summary'] ?? {}),

      alerts: (data['alerts'] as List? ?? [])
          .map((e) => AlertModel.fromJson(e))
          .toList(),
    );
  }
}

class Hospital {
  final int id;
  final String name;
  final String description;
  final String city;
  final String status;

  Hospital({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.status,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] ?? 0,

      name: json['name'] ?? "",

      description: json['description'] ?? "",

      city: json['city'] ?? "",

      status: json['status'] ?? "offline",
    );
  }
}

class Summary {
  final int totalFacility;
  final int totalAvailableUnit;
  final int tersedia;
  final int terbatas;
  final int penuh;
  final int percentage;

  Summary({
    required this.totalFacility,
    required this.totalAvailableUnit,
    required this.tersedia,
    required this.terbatas,
    required this.penuh,
    required this.percentage,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalFacility: int.tryParse(json['total_facility'].toString()) ?? 0,

      totalAvailableUnit:
          int.tryParse(json['total_available_unit'].toString()) ?? 0,

      tersedia: int.tryParse(json['tersedia'].toString()) ?? 0,

      terbatas: int.tryParse(json['terbatas'].toString()) ?? 0,

      penuh: int.tryParse(json['penuh'].toString()) ?? 0,

      percentage: int.tryParse(json['percentage'].toString()) ?? 0,
    );
  }
}

class AlertModel {
  final int facilityId;
  final String facilityName;
  final int available;
  final int total;
  final double percentage;
  final String status;

  AlertModel({
    required this.facilityId,
    required this.facilityName,
    required this.available,
    required this.total,
    required this.percentage,
    required this.status,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      facilityId: json['facility_id'] ?? 0,

      facilityName: json['facility_name'] ?? "",

      available: int.tryParse(json['available'].toString()) ?? 0,

      total: int.tryParse(json['total'].toString()) ?? 0,

      percentage: double.tryParse(json['percentage'].toString()) ?? 0,

      status: json['status'] ?? "terbatas",
    );
  }
}
