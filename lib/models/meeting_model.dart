class AgendaItem {
  final int id;
  final int orderIndex;
  final String title;

  const AgendaItem({required this.id, required this.orderIndex, required this.title});

  factory AgendaItem.fromJson(Map<String, dynamic> json) => AgendaItem(
        id: json['id'] as int? ?? 0,
        orderIndex: json['orderIndex'] as int? ?? 0,
        title: json['title'] as String? ?? '',
      );
}

class MeetingDocument {
  final int id;
  final String fileName;
  final String? fileUrl;
  final double? fileSizeKb;

  const MeetingDocument({required this.id, required this.fileName, this.fileUrl, this.fileSizeKb});

  factory MeetingDocument.fromJson(Map<String, dynamic> json) => MeetingDocument(
        id: json['id'] as int? ?? 0,
        fileName: json['fileName'] as String? ?? '',
        fileUrl: json['fileUrl']?.toString(),
        fileSizeKb: (json['fileSizeKb'] as num?)?.toDouble(),
      );

  String get sizeLabel {
    if (fileSizeKb == null) return '';
    if (fileSizeKb! >= 1024) return '${(fileSizeKb! / 1024).toStringAsFixed(1)} MB';
    return '${fileSizeKb!.toInt()} KB';
  }
}

class MeetingDetailModel {
  final int id;
  final String title;
  final String? location;
  final String type;
  final String status;
  final String? mode;
  final String? meetingDate;
  final String? meetingStartTime;
  final String? meetingEndTime;
  final String? organizerName;
  final String? description;
  final int participantCount;
  final List<AgendaItem> agendaItems;
  final List<MeetingDocument> documents;

  const MeetingDetailModel({
    required this.id,
    required this.title,
    this.location,
    required this.type,
    required this.status,
    this.mode,
    this.meetingDate,
    this.meetingStartTime,
    this.meetingEndTime,
    this.organizerName,
    this.description,
    required this.participantCount,
    required this.agendaItems,
    required this.documents,
  });

  DateTime? get dateTime {
    if (meetingDate == null) return null;
    try { return DateTime.parse(meetingDate!); } catch (_) { return null; }
  }

  factory MeetingDetailModel.fromJson(Map<String, dynamic> json) =>
      MeetingDetailModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        location: json['location']?.toString(),
        type: json['type'] as String? ?? '',
        status: json['status'] as String? ?? '',
        mode: json['mode']?.toString(),
        meetingDate: json['meetingDate']?.toString(),
        meetingStartTime: json['meetingStartTime']?.toString(),
        meetingEndTime: json['meetingEndTime']?.toString(),
        organizerName: json['organizerName']?.toString(),
        description: json['description']?.toString(),
        participantCount: json['participantCount'] as int? ?? 0,
        agendaItems: (json['agendaItems'] as List? ?? [])
            .map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
        documents: (json['documents'] as List? ?? [])
            .map((e) => MeetingDocument.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class MeetingModel {
  final int id;
  final String title;
  final String type;
  final String status;
  final String? meetingDate;
  final String? meetingStartTime;
  final String? meetingEndTime;
  final String? location;
  final int participantCount;
  final int documentCount;
  final int? residenceId;

  const MeetingModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.meetingDate,
    this.meetingStartTime,
    this.meetingEndTime,
    this.location,
    required this.participantCount,
    required this.documentCount,
    this.residenceId,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) => MeetingModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        type: json['type'] as String? ?? '',
        status: json['status'] as String? ?? '',
        meetingDate: json['meetingDate']?.toString(),
        meetingStartTime: json['meetingStartTime']?.toString(),
        meetingEndTime: json['meetingEndTime']?.toString(),
        location: json['location']?.toString(),
        participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
        documentCount: (json['documentCount'] as num?)?.toInt() ?? 0,
        residenceId: (json['residenceId'] as num?)?.toInt(),
      );

  DateTime? get dateTime {
    if (meetingDate == null) return null;
    try { return DateTime.parse(meetingDate!); } catch (_) {}
    final parts = meetingDate!.split('/');
    if (parts.length == 3) {
      try { return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])); } catch (_) {}
    }
    return null;
  }
}

