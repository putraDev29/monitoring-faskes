// models/hospital_model.dart

import 'package:monitoring_faskes_rsud/models/examination_model.dart';
import 'package:monitoring_faskes_rsud/models/facility_model.dart';

// Helper: parse nilai yang bisa String atau num menjadi int
int _parseInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class HospitalList {
  final int id;
  final String name;
  final String address;
  final String? logo;
  final String status;
  final int percentage;

  HospitalList({
    required this.id,
    required this.name,
    required this.address,
    this.logo,
    required this.status,
    required this.percentage,
  });

  factory HospitalList.fromJson(Map<String, dynamic> json) {
    return HospitalList(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      logo: json['logo'],
      status: json['status'] ?? 'tersedia',
      percentage: _parseInt(json['percentage']),
    );
  }
}

class HospitalSummary {
  final int totalFacility;
  final int totalAvailable;
  final int totalUnit;
  final int percentage;
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
      totalFacility: _parseInt(json['total_facility']),
      totalAvailable: _parseInt(json['total_available']),
      totalUnit: _parseInt(json['total_unit']),
      percentage: _parseInt(json['percentage']),
      status: json['status'] ?? 'tersedia',
    );
  }
}

class HospitalDetail {
  final HospitalList hospital;
  final HospitalSummary summary;
  final List<Facility> facilities;

  HospitalDetail({
    required this.hospital,
    required this.summary,
    required this.facilities,
  });

  factory HospitalDetail.fromJson(Map<String, dynamic> json) {
    return HospitalDetail(
      hospital: HospitalList.fromJson(json['hospital'] as Map<String, dynamic>),
      summary: HospitalSummary.fromJson(json['summary'] as Map<String, dynamic>),
      facilities: (json['facilities'] as List<dynamic>)
          .map((e) => Facility.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}