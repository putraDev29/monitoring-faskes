class ProfileResponse {
  final bool success;
  final String message;
  final ProfileData data;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      message: json['message'],
      data: ProfileData.fromJson(json['data']),
    );
  }
}

class ProfileData {
  final User user;
  final Hospital hospital;

  ProfileData({
    required this.user,
    required this.hospital,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      user: User.fromJson(json['user']),
      hospital: Hospital.fromJson(json['hospital']),
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

class Hospital {
  final int id;
  final String name;
  final String description;
  final String city;
  final String? address;
  final String? phone;
  final String? logo;
  final String status;

  Hospital({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    this.address,
    this.phone,
    this.logo,
    required this.status,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      city: json['city'],
      address: json['address'],
      phone: json['phone'],
      logo: json['logo'],
      status: json['status'],
    );
  }
}