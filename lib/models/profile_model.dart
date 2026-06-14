class ProfileModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? photoUrl;
  final String? memberSince;

  const ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.photoUrl,
    this.memberSince,
  });

  String get fullName => '$firstName $lastName';

  String get memberSinceFormatted {
    if (memberSince == null) return '';
    try {
      final dt = DateTime.parse(memberSince!);
      const months = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      return 'Membre depuis ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Membre depuis $memberSince';
    }
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
        memberSince: json['memberSince']?.toString(),
      );
}
