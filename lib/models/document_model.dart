class DocumentModel {
  final String fileName;
  final String? fileUrl;
  final double? fileSizeKb;
  final String? category;
  final String? sourceType;
  final int? sourceId;
  final String? createdAt;

  const DocumentModel({
    required this.fileName,
    this.fileUrl,
    this.fileSizeKb,
    this.category,
    this.sourceType,
    this.sourceId,
    this.createdAt,
  });

  String get sizeLabel {
    if (fileSizeKb == null) return '';
    if (fileSizeKb! >= 1024) return '${(fileSizeKb! / 1024).toStringAsFixed(1)} MB';
    return '${fileSizeKb!.toInt()} KB';
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        fileName: json['fileName']?.toString() ?? '',
        fileUrl: json['fileUrl']?.toString(),
        fileSizeKb: (json['fileSizeKb'] as num?)?.toDouble(),
        category: json['category']?.toString(),
        sourceType: json['sourceType']?.toString(),
        sourceId: (json['sourceId'] as num?)?.toInt(),
        createdAt: json['createdAt']?.toString(),
      );
}

class DocumentsResponse {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final List<DocumentModel> documents;

  const DocumentsResponse({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.documents,
  });

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) =>
      DocumentsResponse(
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
        currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
        documents: (json['documents'] as List? ?? [])
            .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
