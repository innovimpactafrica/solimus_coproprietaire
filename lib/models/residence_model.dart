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
        constructionYear: (json['constructionYear'] as num?)?.toInt(),
        renovationYear: (json['renovationYear'] as num?)?.toInt(),
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
}
