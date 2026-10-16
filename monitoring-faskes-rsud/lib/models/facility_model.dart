// ===========================
// models/facility_model.dart
// ===========================

class FacilityResponse {
  final bool success;
  final String message;
  final int total;
  final List<Facility> data;

  FacilityResponse({
    required this.success,
    required this.message,
    required this.total,
    required this.data,
  });

  factory FacilityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacilityResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      data: List<Facility>.from(
        (json['data'] ?? []).map(
          (x) => Facility.fromJson(x),
        ),
      ),
    );
  }
}

// ===========================
// FACILITY
// ===========================

class Facility {
  final int id;
  final int hospitalId;
  final int facilityTypeId;

  final int totalUnit;
  final int usedUnit;
  final int availableUnit;

  final String percentage;
  final String status;
  final String note;

  final FacilityType facilityType;

  // NULLABLE
  final String? updatedAt;

  Facility({
    required this.id,
    required this.hospitalId,
    required this.facilityTypeId,
    required this.totalUnit,
    required this.usedUnit,
    required this.availableUnit,
    required this.percentage,
    required this.status,
    required this.note,
    required this.facilityType,
    this.updatedAt,
  });

  factory Facility.fromJson(
    Map<String, dynamic> json,
  ) {
    return Facility(
      id: json['id'] ?? 0,
      hospitalId: json['hospital_id'] ?? 0,
      facilityTypeId: json['facility_type_id'] ?? 0,

      totalUnit: json['total_unit'] ?? 0,
      usedUnit: json['used_unit'] ?? 0,
      availableUnit: json['available_unit'] ?? 0,

      percentage: json['percentage']?.toString() ?? "0",
      status: json['status'] ?? '',
      note: json['note'] ?? '',

      facilityType: FacilityType.fromJson(
        json['facility_type'] ?? {},
      ),

      updatedAt: json['updated_at'],
    );
  }
}

// ===========================
// FACILITY TYPE
// ===========================

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

  factory FacilityType.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacilityType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// ===========================
// EDIT FACILITY MODEL
// ===========================

class EditFacilityModel {
  final int totalUnit;
  final int usedUnit;
  final String? note;

  EditFacilityModel({
    required this.totalUnit,
    required this.usedUnit,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      "total_unit": totalUnit,
      "used_unit": usedUnit,
      "note": note,
    };
  }
}

// ===========================
// HISTORY FACILITY RESPONSE
// ===========================

class HistoryFacilityResponse {
  final bool success;
  final String message;
  final dynamic filter;
  final List<HistoryFacility> data;

  HistoryFacilityResponse({
    required this.success,
    required this.message,
    required this.filter,
    required this.data,
  });

  factory HistoryFacilityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return HistoryFacilityResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      filter: json["filter"],
      data: List<HistoryFacility>.from(
        (json["data"] ?? []).map(
          (x) => HistoryFacility.fromJson(x),
        ),
      ),
    );
  }
}

// ===========================
// HISTORY FACILITY
// ===========================

class HistoryFacility {
  final int id;
  final String action;

  final int beforeTotal;
  final int afterTotal;

  final int beforeUsed;
  final int afterUsed;

  final int beforeAvailable;
  final int afterAvailable;

  final String? beforeStatus;
  final String? afterStatus;

  final String description;

  final DateTime createdAt;

  final Facility? facility;
  final HistoryUser user;

  HistoryFacility({
    required this.id,
    required this.action,
    required this.beforeTotal,
    required this.afterTotal,
    required this.beforeUsed,
    required this.afterUsed,
    required this.beforeAvailable,
    required this.afterAvailable,
    required this.beforeStatus,
    required this.afterStatus,
    required this.description,
    required this.createdAt,
    required this.facility,
    required this.user,
  });

  factory HistoryFacility.fromJson(
    Map<String, dynamic> json,
  ) {
    return HistoryFacility(
      id: json["id"] ?? 0,
      action: json["action"] ?? "",

      beforeTotal: json["before_total"] ?? 0,
      afterTotal: json["after_total"] ?? 0,

      beforeUsed: json["before_used"] ?? 0,
      afterUsed: json["after_used"] ?? 0,

      beforeAvailable:
          json["before_available"] ?? 0,

      afterAvailable:
          json["after_available"] ?? 0,

      beforeStatus: json["before_status"],
      afterStatus: json["after_status"],

      description: json["description"] ?? "",

      createdAt: DateTime.parse(
        json["created_at"],
      ),

      facility: json["facility"] != null
          ? Facility.fromJson(
              json["facility"],
            )
          : null,

      user: HistoryUser.fromJson(
        json["user"] ?? {},
      ),
    );
  }
}

// ===========================
// HISTORY USER
// ===========================

class HistoryUser {
  final int id;
  final String name;
  final String email;

  HistoryUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory HistoryUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return HistoryUser(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      email: json["email"] ?? "",
    );
  }
}