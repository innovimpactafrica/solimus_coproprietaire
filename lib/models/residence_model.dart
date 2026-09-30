class ResidenceModel {
  final int id;
  final String name;
  final String? description;
  final String? fullAddress;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final int? lotsCount;
  final int? constructionYear;
  final int? renovationYear;
  final double? annualBudget;
  final String? healthStatus;
  final int? syndicId;
  final String? syndicName;
  final int? totalCoproprietaires;
  final int? incidentsOuverts;
  final double? tauxImpayes;
  final double? tresorerie;
  final String? createdAt;
  final String? updatedAt;

  const ResidenceModel({
    required this.id,
    required this.name,
    this.description,
    this.fullAddress,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.lotsCount,
    this.constructionYear,
    this.renovationYear,
    this.annualBudget,
    this.healthStatus,
    this.syndicId,
    this.syndicName,
    this.totalCoproprietaires,
    this.incidentsOuverts,
    this.tauxImpayes,
    this.tresorerie,
    this.createdAt,
    this.updatedAt,
  });

  factory ResidenceModel.fromJson(Map<String, dynamic> json) => ResidenceModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        fullAddress: json['fullAddress']?.toString(),
        city: json['city']?.toString(),
        country: json['country']?.toString(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        photoUrl: json['photoUrl']?.toString(),
        lotsCount: (json['lotsCount'] as num?)?.toInt(),
        constructionYear: (json['constructionYear'] as num?)?.toInt() ?? _yearFromDate(json['constructionDate']?.toString()),
        renovationYear: (json['renovationYear'] as num?)?.toInt() ?? _yearFromDate(json['renovationDate']?.toString()),
        annualBudget: (json['annualBudget'] as num?)?.toDouble(),
        healthStatus: json['healthStatus']?.toString(),
        syndicId: (json['syndicId'] as num?)?.toInt(),
        syndicName: json['syndicName']?.toString(),
        totalCoproprietaires: (json['totalCoproprietaires'] as num?)?.toInt(),
        incidentsOuverts: (json['incidentsOuverts'] as num?)?.toInt(),
        tauxImpayes: (json['tauxImpayes'] as num?)?.toDouble(),
        tresorerie: (json['tresorerie'] as num?)?.toDouble(),
        createdAt: json['createdAt']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
      );

  static int? _yearFromDate(String? date) {
    if (date == null || date.isEmpty) return null;
    try { return DateTime.parse(date).year; } catch (_) { return null; }
  }
}

// ─── Sous-modèles inclus dans /travaux-manual/residences ─────────────────────

class ResidenceProperty {
  final int id;
  final String reference;
  final int? floor;
  final double? area;
  final double? share;
  final String? typeName;
  final int? residenceId;
  final String? residenceName;
  final int? ownerId;
  final String? ownerName;
  final int? tenantId;
  final String? tenantName;

  const ResidenceProperty({
    required this.id,
    required this.reference,
    this.floor,
    this.area,
    this.share,
    this.typeName,
    this.residenceId,
    this.residenceName,
    this.ownerId,
    this.ownerName,
    this.tenantId,
    this.tenantName,
  });

  factory ResidenceProperty.fromJson(Map<String, dynamic> json) => ResidenceProperty(
        id: (json['id'] as num?)?.toInt() ?? 0,
        reference: json['reference']?.toString() ?? '',
        floor: (json['floor'] as num?)?.toInt(),
        area: (json['area'] as num?)?.toDouble(),
        share: (json['share'] as num?)?.toDouble(),
        typeName: json['typeName']?.toString(),
        residenceId: (json['residenceId'] as num?)?.toInt(),
        residenceName: json['residenceName']?.toString(),
        ownerId: (json['ownerId'] as num?)?.toInt(),
        ownerName: json['ownerName']?.toString(),
        tenantId: (json['tenantId'] as num?)?.toInt(),
        tenantName: json['tenantName']?.toString(),
      );
}

class ResidenceFacility {
  final int id;
  final String name;
  final String? icon;
  final String? status;
  final String? lastMaintenanceDate;

  const ResidenceFacility({
    required this.id,
    required this.name,
    this.icon,
    this.status,
    this.lastMaintenanceDate,
  });

  factory ResidenceFacility.fromJson(Map<String, dynamic> json) => ResidenceFacility(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        icon: json['icon']?.toString(),
        status: json['status']?.toString(),
        lastMaintenanceDate: json['lastMaintenanceDate']?.toString(),
      );
}

class ResidenceSecurityFeature {
  final int id;
  final String label;
  final String? icon;

  const ResidenceSecurityFeature({
    required this.id,
    required this.label,
    this.icon,
  });

  factory ResidenceSecurityFeature.fromJson(Map<String, dynamic> json) => ResidenceSecurityFeature(
        id: (json['id'] as num?)?.toInt() ?? 0,
        label: json['label']?.toString() ?? '',
        icon: json['icon']?.toString(),
      );
}

/// Résidence enrichie retournée par /api/owner/travaux-manual/residences
/// Contient les propriétés, équipements et sécurités directement dans la réponse.
class TravauManualResidence extends ResidenceModel {
  final List<ResidenceProperty> properties;
  final List<ResidenceFacility> facilities;
  final List<ResidenceSecurityFeature> securityFeatures;

  const TravauManualResidence({
    required super.id,
    required super.name,
    super.description,
    super.fullAddress,
    super.city,
    super.country,
    super.latitude,
    super.longitude,
    super.photoUrl,
    super.lotsCount,
    super.constructionYear,
    super.renovationYear,
    super.annualBudget,
    super.healthStatus,
    super.syndicId,
    super.syndicName,
    super.totalCoproprietaires,
    super.incidentsOuverts,
    super.tauxImpayes,
    super.tresorerie,
    super.createdAt,
    super.updatedAt,
    required this.properties,
    required this.facilities,
    required this.securityFeatures,
  });

  factory TravauManualResidence.fromJson(Map<String, dynamic> json) {
    final base = ResidenceModel.fromJson(json);
    return TravauManualResidence(
      id: base.id,
      name: base.name,
      description: base.description,
      fullAddress: base.fullAddress,
      city: base.city,
      country: base.country,
      latitude: base.latitude,
      longitude: base.longitude,
      photoUrl: base.photoUrl,
      lotsCount: base.lotsCount,
      constructionYear: base.constructionYear,
      renovationYear: base.renovationYear,
      annualBudget: base.annualBudget,
      healthStatus: base.healthStatus,
      syndicId: base.syndicId,
      syndicName: base.syndicName,
      totalCoproprietaires: base.totalCoproprietaires,
      incidentsOuverts: base.incidentsOuverts,
      tauxImpayes: base.tauxImpayes,
      tresorerie: base.tresorerie,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      properties: (json['properties'] as List? ?? [])
          .map((e) => ResidenceProperty.fromJson(e as Map<String, dynamic>))
          .toList(),
      facilities: (json['facilities'] as List? ?? [])
          .map((e) => ResidenceFacility.fromJson(e as Map<String, dynamic>))
          .toList(),
      securityFeatures: (json['securityFeatures'] as List? ?? [])
          .map((e) => ResidenceSecurityFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
