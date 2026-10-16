class DashboardModel {
  final int totalHospital;
  final SummaryModel summary;
  final List<CriticalAlertModel> criticalAlerts;

  DashboardModel({
    required this.totalHospital,
    required this.summary,
    required this.criticalAlerts,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return DashboardModel(
      totalHospital: data['total_hospital'] ?? 0,

      summary: SummaryModel.fromJson(
        data['summary'] ?? {},
      ),

      criticalAlerts: List<CriticalAlertModel>.from(
        (data['critical_alerts'] ?? []).map(
          (x) => CriticalAlertModel.fromJson(x),
        ),
      ),
    );
  }
}

class SummaryModel {
  final int totalFacility;
  final int totalAvailable;
  final int tersedia;
  final int terbatas;
  final int penuh;
  final int percentage;

  SummaryModel({
    required this.totalFacility,
    required this.totalAvailable,
    required this.tersedia,
    required this.terbatas,
    required this.penuh,
    required this.percentage,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      totalFacility:
          int.tryParse(json['total_facility'].toString()) ?? 0,

      totalAvailable:
          int.tryParse(json['total_available'].toString()) ?? 0,

      tersedia: int.tryParse(json['tersedia'].toString()) ?? 0,

      terbatas: int.tryParse(json['terbatas'].toString()) ?? 0,

      penuh: int.tryParse(json['penuh'].toString()) ?? 0,

      percentage:
          int.tryParse(json['percentage'].toString()) ?? 0,
    );
  }
}

class CriticalAlertModel {
  final int id;
  final int hospitalId;
  final int facilityTypeId;

  final int totalUnit;
  final int usedUnit;
  final int availableUnit;

  final double percentage;

  final String status;
  final String note;

  final HospitalModel hospital;
  final FacilityTypeModel facilityType;

  CriticalAlertModel({
    required this.id,
    required this.hospitalId,
    required this.facilityTypeId,
    required this.totalUnit,
    required this.usedUnit,
    required this.availableUnit,
    required this.percentage,
    required this.status,
    required this.note,
    required this.hospital,
    required this.facilityType,
  });

  factory CriticalAlertModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CriticalAlertModel(
      id: json['id'] ?? 0,

      hospitalId: json['hospital_id'] ?? 0,

      facilityTypeId: json['facility_type_id'] ?? 0,

      totalUnit: json['total_unit'] ?? 0,

      usedUnit: json['used_unit'] ?? 0,

      availableUnit: json['available_unit'] ?? 0,

      percentage:
          double.tryParse(json['percentage'].toString()) ??
              0.0,

      status: json['status'] ?? '',

      note: json['note'] ?? '',

      hospital: HospitalModel.fromJson(
        json['hospital'] ?? {},
      ),

      facilityType: FacilityTypeModel.fromJson(
        json['facility_type'] ?? {},
      ),
    );
  }
}

class HospitalModel {
  final int id;

  final String name;
  final String description;
  final String city;
  final String address;
  final String phone;
  final String status;

  final String? logo;

  HospitalModel({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.phone,
    required this.status,
    this.logo,
  });

  factory HospitalModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HospitalModel(
      id: json['id'] ?? 0,

      name: json['name'] ?? '',

      description: json['description'] ?? '',

      city: json['city'] ?? '',

      address: json['address'] ?? '',

      phone: json['phone'] ?? '',

      status: json['status'] ?? '',

      logo: json['logo'],
    );
  }
}

class FacilityTypeModel {
  final int id;

  final String name;
  final String icon;
  final String color;
  final String description;

  FacilityTypeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  factory FacilityTypeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacilityTypeModel(
      id: json['id'] ?? 0,

      name: json['name'] ?? '',

      icon: json['icon'] ?? '',

      color: json['color'] ?? '',

      description: json['description'] ?? '',
    );
  }
}