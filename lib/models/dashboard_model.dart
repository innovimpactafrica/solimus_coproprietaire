import 'meeting_model.dart';

class DashboardProperty {
  final int id;
  final String reference;
  final String residenceName;

  const DashboardProperty({
    required this.id,
    required this.reference,
    required this.residenceName,
  });

  factory DashboardProperty.fromJson(Map<String, dynamic> json) =>
      DashboardProperty(
        id: (json['id'] as num?)?.toInt() ?? 0,
        reference: json['reference']?.toString() ?? '',
        residenceName: json['residenceName']?.toString() ?? '',
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

class DashboardModel {
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final List<DashboardProperty> properties;
  final int selectedPropertyId;
  final int totalDocuments;
  final List<DashboardCharge> chargesEnAttente;
  final List<MeetingModel> prochainesReunions;
  final double soldeActuelResidence;
  final double montantArrieresResidence;

  const DashboardModel({
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.properties,
    required this.selectedPropertyId,
    required this.totalDocuments,
    required this.chargesEnAttente,
    required this.prochainesReunions,
    required this.soldeActuelResidence,
    required this.montantArrieresResidence,
  });

  String get fullName => '$firstName $lastName'.trim();

  DashboardProperty? get selectedProperty {
    try {
      return properties.firstWhere((p) => p.id == selectedPropertyId);
    } catch (_) {
      return properties.isNotEmpty ? properties.first : null;
    }
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        photoUrl: json['photoUrl']?.toString(),
        properties: (json['properties'] as List? ?? [])
            .map((e) => DashboardProperty.fromJson(e as Map<String, dynamic>))
            .toList(),
        selectedPropertyId: (json['selectedPropertyId'] as num?)?.toInt() ?? 0,
        totalDocuments: (json['totalDocuments'] as num?)?.toInt() ?? 0,
        chargesEnAttente: (json['chargesEnAttente'] as List? ?? [])
            .map((e) => DashboardCharge.fromJson(e as Map<String, dynamic>))
            .toList(),
        prochainesReunions: (json['prochainesReunions'] as List? ?? [])
            .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        soldeActuelResidence:
            (json['soldeActuelResidence'] as num?)?.toDouble() ?? 0,
        montantArrieresResidence:
            (json['montantArrieresResidence'] as num?)?.toDouble() ?? 0,
      );
}
