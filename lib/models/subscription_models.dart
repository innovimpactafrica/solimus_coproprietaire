DateTime _parseDate(String? s) {
  if (s == null || s.isEmpty) return DateTime.now();
  try { return DateTime.parse(s); } catch (_) { return DateTime.now(); }
}

class PaymentInitResponse {
  final bool success;
  final String transactionReference;
  final int amountToPay;
  final String paymentUrl;

  const PaymentInitResponse({
    required this.success,
    required this.transactionReference,
    required this.amountToPay,
    required this.paymentUrl,
  });

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) =>
      PaymentInitResponse(
        success: json['success'] as bool? ?? false,
        transactionReference: json['transactionReference'] as String? ?? '',
        amountToPay: (json['amountToPay'] as num?)?.toInt() ?? 0,
        paymentUrl: json['paymentUrl'] as String? ?? '',
      );
}

class PaymentHistory {
  final String reference;
  final String plan;
  final double montant;
  final DateTime date;
  final String moyenPaiement;
  final String statut;

  const PaymentHistory({
    required this.reference,
    required this.plan,
    required this.montant,
    required this.date,
    required this.moyenPaiement,
    required this.statut,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => PaymentHistory(
        reference: json['reference'] as String? ?? '',
        plan: json['plan'] as String? ?? '',
        montant: (json['montant'] as num?)?.toDouble() ?? 0,
        date: _parseDate(json['date'] as String?),
        moyenPaiement: json['moyenPaiement'] as String? ?? '',
        statut: json['statut'] as String? ?? '',
      );
}

class SubscriptionInfo {
  final String plan;
  final String status;
  final bool active;
  final DateTime dateActivation;
  final DateTime dateExpiration;
  final String moyenPaiement;
  final bool renouvellementAuto;
  final List<String> avantages;
  final List<PaymentHistory> historiquePaiements;

  const SubscriptionInfo({
    required this.plan,
    required this.status,
    required this.active,
    required this.dateActivation,
    required this.dateExpiration,
    required this.moyenPaiement,
    required this.renouvellementAuto,
    required this.avantages,
    required this.historiquePaiements,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      SubscriptionInfo(
        plan: json['plan'] as String? ?? '',
        status: json['status'] as String? ?? '',
        active: json['active'] as bool? ?? false,
        dateActivation: _parseDate(json['dateActivation'] as String?),
        dateExpiration: _parseDate(json['dateExpiration'] as String?),
        moyenPaiement: json['moyenPaiement'] as String? ?? '',
        renouvellementAuto: json['renouvellementAuto'] as bool? ?? false,
        avantages: (json['avantages'] as List? ?? [])
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList(),
        historiquePaiements: (json['historiquePaiements'] as List? ?? [])
            .map((e) => PaymentHistory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
