class LoginResponse {
  final String accessToken;
  final String email;
  final String role;
  final int id;
  final String firstName;
  final String lastName;
  final String status;
  final bool otpRequired;

  const LoginResponse({
    required this.accessToken,
    required this.email,
    required this.role,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.otpRequired,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: (json['accessToken'] ?? json['token'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        role: (json['role'] ?? '') as String,
        id: (json['id'] as num? ?? 0).toInt(),
        firstName: (json['firstName'] ?? '') as String,
        lastName: (json['lastName'] ?? '') as String,
        status: (json['status'] ?? '') as String,
        otpRequired: json['otpRequired'] as bool? ?? false,
      );
}
