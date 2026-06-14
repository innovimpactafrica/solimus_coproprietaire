class PropertyModel {
  final int id;
  final String name;
  final String? reference;
  final double? superficie;
  final String? type;
  final int? residenceId;
  final String? residenceName;
  final int? ownerId;
  final String? ownerName;

  const PropertyModel({
    required this.id,
    required this.name,
    this.reference,
    this.superficie,
    this.type,
    this.residenceId,
    this.residenceName,
    this.ownerId,
    this.ownerName,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: (json['reference'] ??
                json['name'] ??
                json['number'] ??
                json['apartmentNumber'] ??
                json['label'] ??
                'Appt ${json['id']}')
            .toString(),
        reference: json['reference']?.toString(),
        superficie: (json['superficie'] as num?)?.toDouble(),
        type: json['type']?.toString(),
        residenceId: (json['residenceId'] as num?)?.toInt(),
        residenceName: json['residenceName']?.toString(),
        ownerId: (json['ownerId'] as num?)?.toInt(),
        ownerName: json['ownerName']?.toString(),
      );
}
