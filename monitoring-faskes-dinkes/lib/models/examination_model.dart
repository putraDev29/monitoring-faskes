// models/examination_model.dart

class Examination {
  final int id;
  final int hospitalId;
  final String examinationName;
  final String doctorName;
  final String openingHours;
  final String closingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Examination({
    required this.id,
    required this.hospitalId,
    required this.examinationName,
    required this.doctorName,
    required this.openingHours,
    required this.closingHours,
    this.createdAt,
    this.updatedAt,
  });

  factory Examination.fromJson(Map<String, dynamic> json) {
    return Examination(
      id: json['id'],
      hospitalId: json['hospital_id'],
      examinationName: json['examination_name'],
      doctorName: json['doctor_name'],
      openingHours: json['opening_hours'],
      closingHours: json['closing_hours'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospital_id': hospitalId,
      'examination_name': examinationName,
      'doctor_name': doctorName,
      'opening_hours': openingHours,
      'closing_hours': closingHours,
    };
  }
}