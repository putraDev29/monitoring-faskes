class HospitalModels {
  final bool success;
  final String message;
  final int total;
  final List<HospitalData> data;

  HospitalModels({
    required this.success,
    required this.message,
    required this.total,
    required this.data,
  });

  factory HospitalModels.fromJson(Map<String, dynamic> json) {
    return HospitalModels(
      success: json['success'] ?? false,

      message: json['message'] ?? '',

      total: json['total'] ?? 0,

      data: List<HospitalData>.from(
        (json['data'] ?? []).map((x) => HospitalData.fromJson(x)),
      ),
    );
  }
}

class HospitalData {
  final int id;
  final String? logo;
  final String name;
  final String address;
  final String status;
  final int percentage;

  HospitalData({
    required this.id,
    required this.logo,
    required this.name,
    required this.address,
    required this.status,
    required this.percentage,
  });

  factory HospitalData.fromJson(Map<String, dynamic> json) {
    return HospitalData(
      id: json['id'] ?? 0,

      logo: json['logo'],

      name: json['name'] ?? '',

      address: json['address'] ?? '',

      status: json['status'] ?? '',

      percentage: int.tryParse(json['percentage'].toString()) ?? 0,
    );
  }
}

// models/detail_hospital_model.dart

class DetailHospitalModel {
  final bool success;
  final String message;
  final DetailHospitalData data;

  DetailHospitalModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DetailHospitalModel.fromJson(Map<String, dynamic> json) {
    return DetailHospitalModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DetailHospitalData.fromJson(json['data'] ?? {}),
    );
  }
}

class DetailHospitalData {
  final Hospital hospital;
  final HospitalSummary summary;
  final List<HospitalFacility> facilities;

  DetailHospitalData({
    required this.hospital,
    required this.summary,
    required this.facilities,
  });

  factory DetailHospitalData.fromJson(Map<String, dynamic> json) {
    return DetailHospitalData(
      hospital: Hospital.fromJson(json['hospital'] ?? {}),
      summary: HospitalSummary.fromJson(json['summary'] ?? {}),
      facilities: List<HospitalFacility>.from(
        (json['facilities'] ?? []).map((x) => HospitalFacility.fromJson(x)),
      ),
    );
  }
}

class Hospital {
  final int id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String phone;
  final String? logo;
  final String status;

  Hospital({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.phone,
    required this.logo,
    required this.status,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      logo: json['logo'],
      status: json['status'] ?? '',
    );
  }
}

class HospitalSummary {
  final int totalFacility;
  final String totalAvailable;
  final String totalUnit;
  final String percentage;
  final String status;

  HospitalSummary({
    required this.totalFacility,
    required this.totalAvailable,
    required this.totalUnit,
    required this.percentage,
    required this.status,
  });

  factory HospitalSummary.fromJson(Map<String, dynamic> json) {
    return HospitalSummary(
      totalFacility: json['total_facility'] ?? 0,
      totalAvailable: json['total_available'] ?? '0',
      totalUnit: json['total_unit'] ?? '0',
      percentage: json['percentage'] ?? '0',
      status: json['status'] ?? '',
    );
  }
}

class HospitalFacility {
  final int id;
  final int totalUnit;
  final int usedUnit;
  final int availableUnit;
  final String percentage;
  final String status;
  final String note;
  final FacilityType facilityType;

  HospitalFacility({
    required this.id,
    required this.totalUnit,
    required this.usedUnit,
    required this.availableUnit,
    required this.percentage,
    required this.status,
    required this.note,
    required this.facilityType,
  });

  factory HospitalFacility.fromJson(Map<String, dynamic> json) {
    return HospitalFacility(
      id: json['id'] ?? 0,
      totalUnit: json['total_unit'] ?? 0,
      usedUnit: json['used_unit'] ?? 0,
      availableUnit: json['available_unit'] ?? 0,
      percentage: json['percentage'] ?? '0',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      facilityType: FacilityType.fromJson(json['facility_type'] ?? {}),
    );
  }
}

class FacilityType {
  final int id;
  final String name;
  final String icon;
  final String color;
  final String description;

  FacilityType({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  factory FacilityType.fromJson(Map<String, dynamic> json) {
    return FacilityType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
