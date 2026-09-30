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
  final String? documentTypeLabel;

  const MeetingDocument({required this.id, required this.fileName, this.fileUrl, this.fileSizeKb, this.documentTypeLabel});

  factory MeetingDocument.fromJson(Map<String, dynamic> json) => MeetingDocument(
        id: (json['id'] as num?)?.toInt() ?? 0,
        fileName: json['fileName'] as String? ?? '',
        fileUrl: json['fileUrl']?.toString(),
        fileSizeKb: (json['fileSizeKb'] as num?)?.toDouble(),
        documentTypeLabel: json['documentTypeLabel']?.toString(),
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
  final String typeLabel;
  final String status;
  final String statusLabel;
  final String? meetingDate;
  final String? meetingStartTime;
  final String? meetingEndTime;
  final String? organizerName;
  final String? description;
  final int participantCount;
  final int documentsTotalCount;
  final List<AgendaItem> agendaItems;
  final List<MeetingDocument> documents;

  const MeetingDetailModel({
    required this.id,
    required this.title,
    this.location,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.statusLabel,
    this.meetingDate,
    this.meetingStartTime,
    this.meetingEndTime,
    this.organizerName,
    this.description,
    required this.participantCount,
    required this.documentsTotalCount,
    required this.agendaItems,
    required this.documents,
  });

  static String? _timeFromMap(dynamic t) {
    if (t == null) return null;
    if (t is String) {
      final parts = t.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return t;
    }
    if (t is Map) {
      final h = (t['hour'] as num?)?.toInt() ?? 0;
      final m = (t['minute'] as num?)?.toInt() ?? 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    return null;
  }

  DateTime? get dateTime {
    if (meetingDate == null) return null;
    try { return DateTime.parse(meetingDate!); } catch (_) { return null; }
  }

  factory MeetingDetailModel.fromJson(Map<String, dynamic> json) =>
      MeetingDetailModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        location: json['location']?.toString(),
        type: json['type'] as String? ?? '',
        typeLabel: json['typeLabel'] as String? ?? json['type'] as String? ?? '',
        status: json['status'] as String? ?? '',
        statusLabel: json['statusLabel'] as String? ?? json['status'] as String? ?? '',
        meetingDate: json['meetingDate']?.toString(),
        meetingStartTime: _timeFromMap(json['startTime'] ?? json['meetingStartTime']),
        meetingEndTime: _timeFromMap(json['endTime'] ?? json['meetingEndTime']),
        organizerName: json['organizerName']?.toString(),
        description: json['description']?.toString(),
        participantCount: (json['totalParticipants'] as num?)?.toInt() ??
            (json['participantCount'] as num?)?.toInt() ?? 0,
        documentsTotalCount: (json['documentsTotalCount'] as num?)?.toInt() ?? 0,
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
  final String typeLabel;
  final String status;
  final String statusLabel;
  final String? meetingDate;
  final String? meetingStartTime;
  final String? meetingEndTime;
  final String? location;
  final int participantCount;
  final int documentCount;

  const MeetingModel({
    required this.id,
    required this.title,
    required this.type,
    required this.typeLabel,
    required this.status,
    required this.statusLabel,
    this.meetingDate,
    this.meetingStartTime,
    this.meetingEndTime,
    this.location,
    required this.participantCount,
    required this.documentCount,
  });

  static String? _timeFromMap(dynamic t) {
    if (t == null) return null;
    if (t is String) {
      final parts = t.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return t;
    }
    if (t is Map) {
      final h = (t['hour'] as num?)?.toInt() ?? 0;
      final m = (t['minute'] as num?)?.toInt() ?? 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    return null;
  }

  factory MeetingModel.fromJson(Map<String, dynamic> json) => MeetingModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        type: json['type'] as String? ?? '',
        typeLabel: json['typeLabel'] as String? ?? json['type'] as String? ?? '',
        status: json['status'] as String? ?? '',
        statusLabel: json['statusLabel'] as String? ?? json['status'] as String? ?? '',
        meetingDate: json['meetingDate']?.toString(),
        meetingStartTime: _timeFromMap(json['startTime'] ?? json['meetingStartTime']),
        meetingEndTime: _timeFromMap(json['endTime'] ?? json['meetingEndTime']),
        location: json['location']?.toString(),
        participantCount: (json['participantsCount'] as num?)?.toInt() ??
            (json['participantCount'] as num?)?.toInt() ?? 0,
        documentCount: (json['documentsCount'] as num?)?.toInt() ??
            (json['documentCount'] as num?)?.toInt() ?? 0,
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
