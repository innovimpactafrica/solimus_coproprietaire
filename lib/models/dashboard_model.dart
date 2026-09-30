class DashboardHeader {
  final String firstName;
  final String? photoUrl;
  final int unreadNotificationsCount;
  final String? residencePhotoUrl;

  const DashboardHeader({
    required this.firstName,
    this.photoUrl,
    required this.unreadNotificationsCount,
    this.residencePhotoUrl,
  });

  factory DashboardHeader.fromJson(Map<String, dynamic> json) {
    final rawResidencePhoto = json['residencePhotoUrl']?.toString() ?? json['residencePhoto']?.toString() ?? json['residence_photo']?.toString();
    final formattedResidencePhoto = (rawResidencePhoto != null && rawResidencePhoto.isNotEmpty)
        ? (rawResidencePhoto.startsWith('http')
            ? rawResidencePhoto
            : rawResidencePhoto.startsWith('/')
                ? 'https://api.solimus.sn$rawResidencePhoto'
                : 'https://api.solimus.sn/api/files/$rawResidencePhoto')
        : null;

    final rawPhoto = json['photoUrl']?.toString() ?? json['photo']?.toString();
    final formattedPhoto = (rawPhoto != null && rawPhoto.isNotEmpty)
        ? (rawPhoto.startsWith('http')
            ? rawPhoto
            : rawPhoto.startsWith('/')
                ? 'https://api.solimus.sn$rawPhoto'
                : 'https://api.solimus.sn/api/files/$rawPhoto')
        : null;

    return DashboardHeader(
      firstName: json['firstName']?.toString() ?? '',
      photoUrl: formattedPhoto,
      unreadNotificationsCount: (json['unreadNotificationsCount'] as num?)?.toInt() ?? 0,
      residencePhotoUrl: formattedResidencePhoto,
    );
  }
}

class DashboardKpis {
  final double annualCharge;
  final double remainingToPay;

  const DashboardKpis({required this.annualCharge, required this.remainingToPay});

  factory DashboardKpis.fromJson(Map<String, dynamic> json) => DashboardKpis(
        annualCharge: (json['annualCharge'] as num?)?.toDouble() ?? 0,
        remainingToPay: (json['remainingToPay'] as num?)?.toDouble() ?? 0,
      );
}

class DashboardNotification {
  final int id;
  final String title;
  final String body;
  final bool read;
  final String createdAt;

  const DashboardNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory DashboardNotification.fromJson(Map<String, dynamic> json) => DashboardNotification(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        read: json['read'] as bool? ?? false,
        createdAt: json['createdAt']?.toString() ?? '',
      );
}

class DashboardNotificationsResponse {
  final int totalCount;
  final List<DashboardNotification> notifications;
  final int currentPage;
  final int totalPages;

  const DashboardNotificationsResponse({
    required this.totalCount,
    required this.notifications,
    required this.currentPage,
    required this.totalPages,
  });

  factory DashboardNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      DashboardNotificationsResponse(
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        notifications: (json['notifications'] as List? ?? [])
            .map((e) => DashboardNotification.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      );
}

class DashboardPendingCharge {
  final int chargeCallItemId;
  final String title;
  final String? residenceName;
  final String? propertyReference;
  final String? dueDate;
  final double remainingAmount;
  final String status;

  const DashboardPendingCharge({
    required this.chargeCallItemId,
    required this.title,
    this.residenceName,
    this.propertyReference,
    this.dueDate,
    required this.remainingAmount,
    required this.status,
  });

  factory DashboardPendingCharge.fromJson(Map<String, dynamic> json) => DashboardPendingCharge(
        chargeCallItemId: (json['chargeCallItemId'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        residenceName: json['residenceName']?.toString(),
        propertyReference: json['propertyReference']?.toString(),
        dueDate: json['dueDate']?.toString(),
        remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
        status: json['status']?.toString() ?? '',
      );
}

class DashboardProperty {
  final int propertyId;
  final int residenceId;
  final String residenceName;
  final String propertyReference;

  const DashboardProperty({
    required this.propertyId,
    required this.residenceId,
    required this.residenceName,
    required this.propertyReference,
  });

  factory DashboardProperty.fromJson(Map<String, dynamic> json) =>
      DashboardProperty(
        propertyId: (json['propertyId'] as num?)?.toInt() ?? 0,
        residenceId: (json['residenceId'] as num?)?.toInt() ?? 0,
        residenceName: json['residenceName']?.toString() ?? '',
        propertyReference: json['propertyReference']?.toString() ?? '',
      );
}

class DashboardCharge {
  final int id;
  final String title;
  final double amount;
  final String? dueDate;
  final String status;
  final String? typeBien;
  final String? residenceName;

  const DashboardCharge({
    required this.id,
    required this.title,
    required this.amount,
    this.dueDate,
    required this.status,
    this.typeBien,
    this.residenceName,
  });

  factory DashboardCharge.fromJson(Map<String, dynamic> json) => DashboardCharge(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        dueDate: json['dueDate']?.toString(),
        status: json['status']?.toString() ?? 'EN_ATTENTE',
        typeBien: json['typeBien']?.toString(),
        residenceName: json['residenceName']?.toString(),
      );
}
