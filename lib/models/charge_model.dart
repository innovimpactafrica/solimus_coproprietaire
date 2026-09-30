class ChargeModel {
  final int id;
  final int allocationId;
  final String title;
  final String type;
  final String? typeLabel;
  final double amount;
  final String? dueDate;
  final String status;
  final int? propertyId;
  final String? residenceName;
  final String? propertyReference;
  final bool paymentBlocked;

  const ChargeModel({
    required this.id,
    required this.allocationId,
    required this.title,
    required this.type,
    this.typeLabel,
    required this.amount,
    this.dueDate,
    required this.status,
    this.propertyId,
    this.residenceName,
    this.propertyReference,
    this.paymentBlocked = false,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory ChargeModel.fromJson(Map<String, dynamic> json) => ChargeModel(
        id: _toInt(json['idAllocation'] ?? json['id']),
        allocationId: _toInt(json['idAllocation'] ?? json['id']),
        title: (json['title'] ?? json['label'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        typeLabel: json['typeLabel']?.toString(),
        amount: _toDouble(json['remainingAmount'] ?? json['amount']),
        dueDate: json['dueDate']?.toString(),
        status: (json['status'] ?? 'EN_ATTENTE').toString(),
        propertyId: json['propertyId'] == null ? null : _toInt(json['propertyId']),
        residenceName: json['residenceName']?.toString(),
        propertyReference: json['propertyReference']?.toString(),
        paymentBlocked: json['paymentBlocked'] as bool? ?? false,
      );
}

class PaymentReceiptModel {
  final String reference;
  final String chargeTitle;
  final double amount;
  final String method;
  final String? paidAt;
  final String status;

  const PaymentReceiptModel({
    required this.reference,
    required this.chargeTitle,
    required this.amount,
    required this.method,
    this.paidAt,
    required this.status,
  });

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) =>
      PaymentReceiptModel(
        reference: json['reference'] as String? ?? '',
        chargeTitle: json['chargeTitle'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        method: json['method'] as String? ?? '',
        paidAt: json['paidAt']?.toString(),
        status: json['status'] as String? ?? '',
      );
}

class ChargePaymentResponse {
  final bool success;
  final String? message;
  final String transactionReference;
  final double amount;
  final String paymentUrl;

  const ChargePaymentResponse({
    required this.success,
    this.message,
    required this.transactionReference,
    required this.amount,
    required this.paymentUrl,
  });

  factory ChargePaymentResponse.fromJson(Map<String, dynamic> json) =>
      ChargePaymentResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String?,
        transactionReference: json['transactionReference'] as String? ?? '',
        amount: (json['amountToPay'] as num? ?? json['amount'] as num?)?.toDouble() ?? 0,
        paymentUrl: json['paymentUrl'] as String? ?? '',
      );
}

class ChargeLine {
  final String label;
  final double amount;

  const ChargeLine({required this.label, required this.amount});

  factory ChargeLine.fromJson(Map<String, dynamic> json) => ChargeLine(
        label: json['label'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
      );
}

class ChargeDetailModel {
  final int idAllocation;
  final String? reference;
  final String title;
  final String type;
  final String? typeLabel;
  final double amount;
  final double totalAmount;
  final String? dueDate;
  final String status;
  final String? period;
  final String? residenceName;
  final String? propertyReference;
  final String? description;
  final List<ChargeLine> lines;
  final List<String> documentUrls;
  final String? createdAt;
  final bool paymentBlocked;

  const ChargeDetailModel({
    required this.idAllocation,
    this.reference,
    required this.title,
    required this.type,
    this.typeLabel,
    required this.amount,
    required this.totalAmount,
    this.dueDate,
    required this.status,
    this.period,
    this.residenceName,
    this.propertyReference,
    this.description,
    required this.lines,
    required this.documentUrls,
    this.createdAt,
    this.paymentBlocked = false,
  });

  factory ChargeDetailModel.fromJson(Map<String, dynamic> json) {
    final rawLines = (json['breakdown'] ?? json['lines'] ?? []) as List;
    return ChargeDetailModel(
      idAllocation: (json['idAllocation'] as num? ?? json['id'] as num? ?? 0).toInt(),
      reference: json['reference']?.toString(),
      title: (json['title'] ?? json['typeLabel'] ?? json['type'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      typeLabel: json['typeLabel']?.toString(),
      amount: (json['remainingAmount'] as num? ?? json['amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['breakdownTotal'] as num? ?? json['totalAmount'] as num? ?? json['remainingAmount'] as num? ?? json['amount'] as num?)?.toDouble() ?? 0,
      dueDate: json['dueDate']?.toString(),
      status: (json['status'] ?? 'EN_ATTENTE').toString(),
      period: json['period']?.toString(),
      residenceName: json['residenceName']?.toString(),
      propertyReference: json['propertyReference']?.toString(),
      description: json['description']?.toString(),
      lines: rawLines.map((e) => ChargeLine.fromJson(e as Map<String, dynamic>)).toList(),
      documentUrls: (json['documentUrls'] as List? ?? [])
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      createdAt: (json['issuedDate'] ?? json['createdAt'])?.toString(),
      paymentBlocked: json['paymentBlocked'] as bool? ?? false,
    );
  }
}

class PaymentStatusModel {
  final String reference;
  final String status; // COMPLETED, FAILED, PENDING
  final double amount;
  final String? paidAt;

  const PaymentStatusModel({
    required this.reference,
    required this.status,
    required this.amount,
    this.paidAt,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) =>
      PaymentStatusModel(
        reference: json['reference'] as String? ?? '',
        status: (json['status'] as String? ?? 'PENDING').toUpperCase(),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        paidAt: json['paidAt']?.toString(),
      );
}

class ChargesResponse {
  final double totalAPayer;
  final int chargesEnAttente;
  final String? prochaineEcheance;
  final List<ChargeModel> charges;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  const ChargesResponse({
    required this.totalAPayer,
    required this.chargesEnAttente,
    this.prochaineEcheance,
    required this.charges,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
  });

  factory ChargesResponse.fromJson(Map<String, dynamic> json) {
    final rawList = (json['charges'] ?? json['content'] ?? json['data'] ?? []) as List;
    final charges = rawList
        .map((e) => ChargeModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final summary = json['summary'] as Map<String, dynamic>?;
    return ChargesResponse(
      totalAPayer: (summary?['totalToPay'] as num? ?? json['totalAPayer'] as num?)?.toDouble() ?? 0,
      chargesEnAttente: (summary?['pendingCount'] as num? ?? json['chargesEnAttente'] as num?)?.toInt() ?? 0,
      prochaineEcheance: summary?['nextDueDate']?.toString() ?? json['prochaineEcheance']?.toString(),
      charges: charges,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? charges.length,
      currentPage: (json['currentPage'] ?? json['number'] as num?)?.toInt() ?? 0,
    );
  }
}
