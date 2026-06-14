class DocumentModel {
  final int id;
  final String fileName;
  final String? documentType;
  final String? source;
  final String? date;
  final String? fileSize;
  final String? fileUrl;

  const DocumentModel({
    required this.id,
    required this.fileName,
    this.documentType,
    this.source,
    this.date,
    this.fileSize,
    this.fileUrl,
  });

  static String? _formatSize(dynamic v) {
    if (v == null) return null;
    final kb = double.tryParse(v.toString());
    if (kb == null) return v.toString();
    if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(1)} MB';
    return '${kb.toInt()} KB';
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        fileName: (json['fileName'] ?? json['name'] ?? '').toString(),
        documentType: json['documentType']?.toString(),
        source: json['source']?.toString(),
        date: (json['date'] ?? json['createdAt'] ?? json['uploadedAt'])?.toString(),
        fileSize: _formatSize(json['fileSizeKb'] ?? json['fileSize']),
        fileUrl: (json['fileUrl'] ?? json['url'] ?? json['filePath'])?.toString(),
      );
}

class DocumentsResponse {
  final int totalPages;
  final int totalElements;
  final List<DocumentModel> content;

  const DocumentsResponse({
    required this.totalPages,
    required this.totalElements,
    required this.content,
  });

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) =>
      DocumentsResponse(
        totalPages: json['totalPages'] as int? ?? 0,
        totalElements: json['totalElements'] as int? ?? 0,
        content: (json['content'] as List<dynamic>? ?? [])
            .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
