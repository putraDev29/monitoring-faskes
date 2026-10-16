// models/input_facility_model.dart

class InputFacilityModel {
  final String nameFacility;
  final int totalUnit;
  final String? note;

  InputFacilityModel({
    required this.nameFacility,
    required this.totalUnit,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": nameFacility,
      "total_unit": totalUnit,
      "note": note,
    };
  }
}