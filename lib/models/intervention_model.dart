class InterventionProvider {
  final int id;
  final String firstName;
  final String lastName;
  final String? companyName;
  final String? interventionStatusLabel;

  const InterventionProvider({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.companyName,
    this.interventionStatusLabel,
  });

  String get fullName {
    final company = companyName;
    if (company != null && company.isNotEmpty) return company;
    return '$firstName $lastName'.trim();
  }

  factory InterventionProvider.fromJson(Map<String, dynamic> json) =>
      InterventionProvider(
        id: (json['id'] as num?)?.toInt() ?? 0,
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        companyName: json['companyName']?.toString(),
        interventionStatusLabel: json['interventionStatusLabel']?.toString(),
      );
}

class InterventionTimelineStep {
  final String label;
  final String? date;
  final bool completed;

  const InterventionTimelineStep({
    required this.label,
    this.date,
    required this.completed,
  });

  factory InterventionTimelineStep.fromJson(Map<String, dynamic> json) =>
      InterventionTimelineStep(
        label: json['label']?.toString() ?? '',
        date: json['date']?.toString(),
        completed: json['completed'] as bool? ?? false,
      );
}

class InterventionDetailModel {
  final int id;
  final String title;
  final String? description;
  final String? residenceName;
  final String? typeBien;
  final String? commonFacilityName;
  final String status;
  final String? statusLabel;
  final String? urgencyLevel;
  final String? urgencyLabel;
  final String? specialtyName;
  final String? specialtyIcon;
  final List<String> photoUrls;
  final InterventionProvider? selectedProvider;
  final List<InterventionTimelineStep> timeline;
  final String? createdAt;
  final String? updatedAt;
  final String? startedAt;
  final String? finishedAt;

  const InterventionDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.residenceName,
    this.typeBien,
    this.commonFacilityName,
    required this.status,
    this.statusLabel,
    this.urgencyLevel,
    this.urgencyLabel,
    this.specialtyName,
    this.specialtyIcon,
    required this.photoUrls,
    this.selectedProvider,
    required this.timeline,
    this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.finishedAt,
  });

  String get location {
    final parts = [residenceName, typeBien ?? commonFacilityName]
        .where((e) => e != null && e.isNotEmpty)
        .join(' • ');
    return parts.isNotEmpty ? parts : '—';
  }

  factory InterventionDetailModel.fromJson(Map<String, dynamic> json) =>
      InterventionDetailModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        residenceName: json['residenceName']?.toString(),
        typeBien: json['typeBien']?.toString(),
        commonFacilityName: json['commonFacilityName']?.toString(),
        status: json['status']?.toString() ?? 'PENDING',
        statusLabel: json['statusLabel']?.toString(),
        urgencyLevel: json['urgencyLevel']?.toString(),
        urgencyLabel: json['urgencyLabel']?.toString(),
        specialtyName: json['specialtyName']?.toString(),
        specialtyIcon: json['specialtyIcon']?.toString(),
        photoUrls: (json['photoUrls'] as List? ?? [])
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList(),
        selectedProvider: json['selectedProvider'] != null
            ? InterventionProvider.fromJson(
                json['selectedProvider'] as Map<String, dynamic>)
            : null,
        timeline: (json['timeline'] as List? ?? [])
            .map((e) => InterventionTimelineStep.fromJson(
                e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
        startedAt: json['startedAt']?.toString(),
        finishedAt: json['finishedAt']?.toString(),
      );
}

class QuoteLine {
  final String description;
  final double quantity;
  final double unitPrice;
  final double subtotal;

  const QuoteLine({required this.description, required this.quantity, required this.unitPrice, required this.subtotal});

  factory QuoteLine.fromJson(Map<String, dynamic> json) => QuoteLine(
        description: json['description']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      );
}

class QuoteModel {
  final int id;
  final int providerId;
  final String providerName;
  final String? companyName;
  final String? providerPhotoUrl;
  final String? providerCity;
  final String? providerPhone;
  final String? providerEmail;
  final double providerRating;
  final int reviewCount;
  final int? interventionCount;
  final double? satisfactionRate;
  final String? avgInterventionTime;
  final double? scoreQualitePrix;
  final List<QuoteLine> materialLines;
  final List<QuoteLine> laborLines;
  final double laborTotalAmount;
  final double materialTotalAmount;
  final double totalAmount;
  final double? totalTTC;
  final String? estimatedDelayLabel;
  final String? additionalComments;
  final String status;
  final String? createdAt;
  final bool bestOffer;
  final bool verified;

  const QuoteModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    this.companyName,
    this.providerPhotoUrl,
    this.providerCity,
    this.providerPhone,
    this.providerEmail,
    required this.providerRating,
    required this.reviewCount,
    this.interventionCount,
    this.satisfactionRate,
    this.avgInterventionTime,
    this.scoreQualitePrix,
    required this.materialLines,
    required this.laborLines,
    required this.laborTotalAmount,
    required this.materialTotalAmount,
    required this.totalAmount,
    this.totalTTC,
    this.estimatedDelayLabel,
    this.additionalComments,
    required this.status,
    this.createdAt,
    required this.bestOffer,
    required this.verified,
  });

  String get displayName => (companyName != null && companyName!.isNotEmpty) ? companyName! : providerName;

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        providerId: (json['providerId'] as num?)?.toInt() ?? 0,
        providerName: json['providerName']?.toString() ?? '',
        companyName: json['companyName']?.toString(),
        providerPhotoUrl: json['providerPhotoUrl']?.toString(),
        providerCity: json['providerCity']?.toString(),
        providerPhone: json['providerPhone']?.toString(),
        providerEmail: json['providerEmail']?.toString(),
        providerRating: (json['providerRating'] as num?)?.toDouble() ?? (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        interventionCount: (json['interventionCount'] as num?)?.toInt(),
        satisfactionRate: (json['satisfactionRate'] as num?)?.toDouble() ?? (json['satisfaction'] as num?)?.toDouble(),
        avgInterventionTime: json['avgInterventionTime']?.toString() ?? (json['averageTimeHours'] != null ? '${json['averageTimeHours']}h' : null),
        scoreQualitePrix: (json['scoreQualitePrix'] as num?)?.toDouble(),
        materialLines: (json['materialLines'] as List? ?? json['materiaux'] as List? ?? [])
            .map((e) => QuoteLine.fromJson(e as Map<String, dynamic>)).toList(),
        laborLines: (json['laborLines'] as List? ?? json['mainOeuvre'] as List? ?? [])
            .map((e) => QuoteLine.fromJson(e as Map<String, dynamic>)).toList(),
        laborTotalAmount: (json['laborTotalAmount'] as num?)?.toDouble() ?? (json['sousTotalMainOeuvre'] as num?)?.toDouble() ?? 0,
        materialTotalAmount: (json['materialTotalAmount'] as num?)?.toDouble() ?? (json['sousTotalMateriaux'] as num?)?.toDouble() ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        totalTTC: (json['totalTTC'] as num?)?.toDouble(),
        estimatedDelayLabel: json['estimatedDelayLabel']?.toString(),
        additionalComments: json['additionalComments']?.toString(),
        status: json['status']?.toString() ?? json['quoteStatus']?.toString() ?? 'DRAFT',
        createdAt: json['createdAt']?.toString(),
        bestOffer: json['bestOffer'] as bool? ?? false,
        verified: json['verified'] as bool? ?? false,
      );
}

class InterventionModel {
  final int id;
  final String title;
  final String? residenceName;
  final String? propertyReference;
  final String? commonFacilityName;
  final String? specialtyName;
  final String? specialtyIcon;
  final String status;
  final String? statusLabel;
  final String? urgencyLevel;
  final String? urgencyLabel;
  final String? createdAt;

  const InterventionModel({
    required this.id,
    required this.title,
    this.residenceName,
    this.propertyReference,
    this.commonFacilityName,
    this.specialtyName,
    this.specialtyIcon,
    required this.status,
    this.statusLabel,
    this.urgencyLevel,
    this.urgencyLabel,
    this.createdAt,
  });

  String get location {
    final parts = [residenceName, propertyReference ?? commonFacilityName]
        .where((e) => e != null && e.isNotEmpty)
        .join(' • ');
    return parts.isNotEmpty ? parts : '—';
  }

  factory InterventionModel.fromJson(Map<String, dynamic> json) =>
      InterventionModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        residenceName: json['residenceName']?.toString(),
        propertyReference: json['propertyReference']?.toString(),
        commonFacilityName: json['commonFacilityName']?.toString(),
        specialtyName: json['specialtyName']?.toString(),
        specialtyIcon: json['specialtyIcon']?.toString(),
        status: json['status']?.toString() ?? 'PENDING',
        statusLabel: json['statusLabel']?.toString(),
        urgencyLevel: json['urgencyLevel']?.toString(),
        urgencyLabel: json['urgencyLabel']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );
}

class InterventionsResponse {
  final int totalIncidents;
  final int enCoursCount;
  final List<InterventionModel> interventions;
  final int totalPages;
  final int totalElements;

  const InterventionsResponse({
    required this.totalIncidents,
    required this.enCoursCount,
    required this.interventions,
    required this.totalPages,
    required this.totalElements,
  });

  factory InterventionsResponse.fromJson(Map<String, dynamic> json) {
    final page = json['interventions'] as Map<String, dynamic>? ?? {};
    final content = page['content'] as List? ?? [];
    return InterventionsResponse(
      totalIncidents: (json['totalIncidents'] as num?)?.toInt() ?? 0,
      enCoursCount: (json['enCoursCount'] as num?)?.toInt() ?? 0,
      totalPages: (page['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (page['totalElements'] as num?)?.toInt() ?? 0,
      interventions: content
          .map((e) => InterventionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BalanceSummaryModel {
  final int interventionId;
  final double montantDevis;
  final double acompteVerse;
  final double soldeRestant;

  const BalanceSummaryModel({
    required this.interventionId,
    required this.montantDevis,
    required this.acompteVerse,
    required this.soldeRestant,
  });

  factory BalanceSummaryModel.fromJson(Map<String, dynamic> json) =>
      BalanceSummaryModel(
        interventionId: (json['interventionId'] as num?)?.toInt() ?? 0,
        montantDevis: (json['montantDevis'] as num?)?.toDouble() ?? 0,
        acompteVerse: (json['acompteVerse'] as num?)?.toDouble() ?? 0,
        soldeRestant: (json['soldeRestant'] as num?)?.toDouble() ?? 0,
      );
}

class NearbyProviderModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? companyName;
  final String? specialtyName;
  final double distanceKm;
  final double rating;
  final bool premium;

  const NearbyProviderModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.companyName,
    this.specialtyName,
    required this.distanceKm,
    required this.rating,
    required this.premium,
  });

  String get displayName =>
      (companyName != null && companyName!.isNotEmpty) ? companyName! : '$firstName $lastName';

  factory NearbyProviderModel.fromJson(Map<String, dynamic> json) =>
      NearbyProviderModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        companyName: json['companyName']?.toString(),
        specialtyName: json['specialtyName']?.toString(),
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        premium: json['premium'] as bool? ?? false,
      );
}

class SpecialtyModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;

  const SpecialtyModel({required this.id, required this.name, this.description, this.icon});

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) => SpecialtyModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        icon: json['icon']?.toString(),
      );
}

class CommonFacilityModel {
  final int id;
  final String label;

  const CommonFacilityModel({required this.id, required this.label});

  factory CommonFacilityModel.fromJson(Map<String, dynamic> json) => CommonFacilityModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        label: json['label']?.toString() ?? '',
      );
}

class SignalementModel {
  final int id;
  final String title;
  final String? positionLabel;
  final String? createdAt;
  final String? urgencyLevel;
  final String status;

  const SignalementModel({
    required this.id,
    required this.title,
    this.positionLabel,
    this.createdAt,
    this.urgencyLevel,
    required this.status,
  });

  factory SignalementModel.fromJson(Map<String, dynamic> json) => SignalementModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        positionLabel: json['positionLabel']?.toString(),
        createdAt: json['createdAt']?.toString(),
        urgencyLevel: json['urgencyLevel']?.toString(),
        status: json['status']?.toString() ?? 'PENDING',
      );
}

class SignalementHistoryEntry {
  final String status;
  final String label;
  final String? changedByName;
  final String? date;

  const SignalementHistoryEntry({
    required this.status,
    required this.label,
    this.changedByName,
    this.date,
  });

  factory SignalementHistoryEntry.fromJson(Map<String, dynamic> json) =>
      SignalementHistoryEntry(
        status: json['status']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        changedByName: json['changedByName']?.toString(),
        date: json['date']?.toString(),
      );
}

class SignalementDetailModel {
  final int id;
  final String? reference;
  final String title;
  final String? residenceName;
  final String? positionLabel;
  final String? createdAt;
  final String? urgencyLevel;
  final String status;
  final String? description;
  final List<String> photoUrls;
  final String? declaredByName;
  final String? closingNote;
  final List<SignalementHistoryEntry> history;

  const SignalementDetailModel({
    required this.id,
    this.reference,
    required this.title,
    this.residenceName,
    this.positionLabel,
    this.createdAt,
    this.urgencyLevel,
    required this.status,
    this.description,
    required this.photoUrls,
    this.declaredByName,
    this.closingNote,
    required this.history,
  });

  factory SignalementDetailModel.fromJson(Map<String, dynamic> json) =>
      SignalementDetailModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        reference: json['reference']?.toString(),
        title: json['title']?.toString() ?? '',
        residenceName: json['residenceName']?.toString(),
        positionLabel: json['positionLabel']?.toString(),
        createdAt: json['createdAt']?.toString(),
        urgencyLevel: json['urgencyLevel']?.toString(),
        status: json['status']?.toString() ?? 'PENDING',
        description: json['description']?.toString(),
        photoUrls: (json['photoUrls'] as List? ?? [])
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList(),
        declaredByName: json['declaredByName']?.toString(),
        closingNote: json['closingNote']?.toString(),
        history: (json['history'] as List? ?? [])
            .map((e) => SignalementHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
