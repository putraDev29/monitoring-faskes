class ProfileResponse {
  final bool success;
  final String message;
  final ProfileModel data;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      message: json['message'],
      data: ProfileModel.fromJson(json['data']),
    );
  }
}

class ProfileModel {
  final bool success;
  final String message;
  final User data;

  ProfileModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: User.fromJson(json['data'] ?? {}),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      role: json['role'],
    );
  }
}