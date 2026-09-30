// lib/models/locataire_models.dart
// Modèles de données pour le profil Locataire.
// Ces structures sont conçues pour être facilement remplacées par les réponses API.

// ─── Enums ───────────────────────────────────────────────────────────────────

enum SignalementStatut { enAttente, enCours, resolu }

enum SignalementPriorite { faible, moyenne, haute }

enum TravauxStatut { planifie, enCours, termine, annule }

enum TravauxCategorie { plomberie, peinture, electricite, entretien, autre }

// ─── Notification ─────────────────────────────────────────────────────────────

class LocataireNotification {
  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  const LocataireNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  LocataireNotification copyWith({bool? read}) {
    return LocataireNotification(
      id: id,
      title: title,
      body: body,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }

  factory LocataireNotification.fromJson(Map<String, dynamic> json) {
    return LocataireNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'read': read,
        'createdAt': createdAt.toIso8601String(),
      };
}

// ─── Profil Locataire ────────────────────────────────────────────────────────

class LocataireProfile {
  final String id;
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String residence;
  final String appartement;
  final DateTime dateEntree;
  final String? photoUrl;
  final String? statusLabel;

  const LocataireProfile({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.residence,
    required this.appartement,
    required this.dateEntree,
    this.photoUrl,
    this.statusLabel,
  });

  String get nomComplet => '$prenom $nom'.trim();

  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  /// Conversion depuis JSON API (supporte /api/tenant/profile et ancienne clés)
  factory LocataireProfile.fromJson(Map<String, dynamic> json) {
    final rawDate = json['entryDate']?.toString() ?? json['dateEntree']?.toString();
    return LocataireProfile(
      id: json['id']?.toString() ?? '',
      prenom: json['firstName']?.toString() ?? json['prenom']?.toString() ?? '',
      nom: json['lastName']?.toString() ?? json['nom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telephone: json['phone']?.toString() ?? json['telephone']?.toString() ?? '',
      residence: json['residenceName']?.toString() ?? json['residence']?.toString() ?? '',
      appartement: json['propertyReference']?.toString() ?? json['appartement']?.toString() ?? '',
      dateEntree: rawDate != null
          ? DateTime.tryParse(rawDate) ?? DateTime.now()
          : DateTime.now(),
      photoUrl: json['photoUrl']?.toString(),
      statusLabel: json['statusLabel']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'residence': residence,
        'appartement': appartement,
        'dateEntree': dateEntree.toIso8601String(),
        'photoUrl': photoUrl,
        'statusLabel': statusLabel,
      };
}

// ─── Dashboard Locataire (/api/tenant/dashboard) ───────────────────────────────

class TenantTravauxItem {
  final int id;
  final String title;
  final String? specialtyName;
  final String? specialtyIcon;
  final String? statusLabel;
  final String status;

  const TenantTravauxItem({
    required this.id,
    required this.title,
    this.specialtyName,
    this.specialtyIcon,
    this.statusLabel,
    required this.status,
  });

  factory TenantTravauxItem.fromJson(Map<String, dynamic> json) => TenantTravauxItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        specialtyName: json['specialtyName']?.toString(),
        specialtyIcon: json['specialtyIcon']?.toString(),
        statusLabel: json['statusLabel']?.toString(),
        status: json['status']?.toString() ?? 'PENDING',
      );
}

class TenantDashboardModel {
  final String firstName;
  final String propertyReference;
  final String residenceName;
  final bool bailActif;
  final int pendingReportsCount;
  final int inProgressReportsCount;
  final int resolvedReportsCount;
  final List<TenantTravauxItem> travauxEnCours;
  final String? residencePhotoUrl;

  const TenantDashboardModel({
    required this.firstName,
    required this.propertyReference,
    required this.residenceName,
    required this.bailActif,
    required this.pendingReportsCount,
    required this.inProgressReportsCount,
    required this.resolvedReportsCount,
    required this.travauxEnCours,
    this.residencePhotoUrl,
  });

  factory TenantDashboardModel.fromJson(Map<String, dynamic> json) {
    final list = json['travauxEnCours'] as List? ?? [];
    final rawResidencePhoto = json['residencePhotoUrl']?.toString() ?? json['residencePhoto']?.toString() ?? json['residence_photo']?.toString();
    final formattedResidencePhoto = (rawResidencePhoto != null && rawResidencePhoto.isNotEmpty)
        ? (rawResidencePhoto.startsWith('http')
            ? rawResidencePhoto
            : rawResidencePhoto.startsWith('/')
                ? 'https://api.solimus.sn$rawResidencePhoto'
                : 'https://api.solimus.sn/api/files/$rawResidencePhoto')
        : null;

    return TenantDashboardModel(
      firstName: json['firstName']?.toString() ?? '',
      propertyReference: json['propertyReference']?.toString() ?? '',
      residenceName: json['residenceName']?.toString() ?? '',
      bailActif: json['bailActif'] as bool? ?? true,
      pendingReportsCount: (json['pendingReportsCount'] as num?)?.toInt() ?? 0,
      inProgressReportsCount: (json['inProgressReportsCount'] as num?)?.toInt() ?? 0,
      resolvedReportsCount: (json['resolvedReportsCount'] as num?)?.toInt() ?? 0,
      travauxEnCours: list.map((e) => TenantTravauxItem.fromJson(e as Map<String, dynamic>)).toList(),
      residencePhotoUrl: formattedResidencePhoto,
    );
  }
}

class TenantPropertyModel {
  final String propertyReference;
  final String residenceName;

  const TenantPropertyModel({
    required this.propertyReference,
    required this.residenceName,
  });

  factory TenantPropertyModel.fromJson(Map<String, dynamic> json) => TenantPropertyModel(
        propertyReference: (json['propertyReference'] ?? json['reference'] ?? json['property'] ?? json['lotNumber'] ?? json['appartement'] ?? '').toString(),
        residenceName: (json['residenceName'] ?? json['residence'] ?? json['residence_name'] ?? json['building'] ?? '').toString(),
      );
}

// ─── Signalement API (/api/tenant/signalements) ───────────────────────────────

class TenantSignalementItem {
  final int id;
  final String title;
  final String? positionLabel;
  final DateTime? createdAt;
  final String? urgencyLevel;
  final String status;
  final List<String> photoUrls;
  final bool fromTenant;
  final String? tenantName;

  const TenantSignalementItem({
    required this.id,
    required this.title,
    this.positionLabel,
    this.createdAt,
    this.urgencyLevel,
    required this.status,
    required this.photoUrls,
    required this.fromTenant,
    this.tenantName,
  });

  factory TenantSignalementItem.fromJson(Map<String, dynamic> json) => TenantSignalementItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        positionLabel: json['positionLabel']?.toString(),
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
        urgencyLevel: json['urgencyLevel']?.toString(),
        status: json['status']?.toString() ?? 'PENDING',
        photoUrls: (json['photoUrls'] as List? ?? [])
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .map((e) => e.startsWith('http') ? e : 'https://api.solimus.sn/api/files/$e')
            .toList(),
        fromTenant: json['fromTenant'] as bool? ?? true,
        tenantName: json['tenantName']?.toString(),
      );
}

class TenantSignalementsResponse {
  final int totalElements;
  final int totalPages;
  final List<TenantSignalementItem> content;

  const TenantSignalementsResponse({
    required this.totalElements,
    required this.totalPages,
    required this.content,
  });

  factory TenantSignalementsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List? ?? [];
    return TenantSignalementsResponse(
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      content: list.map((e) => TenantSignalementItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// ─── Détail Signalement API (/api/tenant/signalements/{id}) ─────────────────

class TenantSignalementHistoryItem {
  final String status;
  final String label;
  final String? changedByName;
  final DateTime? date;

  const TenantSignalementHistoryItem({
    required this.status,
    required this.label,
    this.changedByName,
    this.date,
  });

  factory TenantSignalementHistoryItem.fromJson(Map<String, dynamic> json) =>
      TenantSignalementHistoryItem(
        status: json['status']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        changedByName: json['changedByName']?.toString(),
        date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      );
}

class TenantSignalementDetailModel {
  final int id;
  final String? reference;
  final String title;
  final String? residenceName;
  final String? positionLabel;
  final DateTime? createdAt;
  final String? urgencyLevel;
  final String status;
  final String? description;
  final List<String> photoUrls;
  final String? declaredByName;
  final String? closingNote;
  final List<TenantSignalementHistoryItem> history;
  final bool fromTenant;
  final String? tenantName;

  const TenantSignalementDetailModel({
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
    required this.fromTenant,
    this.tenantName,
  });

  factory TenantSignalementDetailModel.fromJson(Map<String, dynamic> json) {
    final hList = json['history'] as List? ?? [];
    return TenantSignalementDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reference: json['reference']?.toString(),
      title: json['title']?.toString() ?? '',
      residenceName: json['residenceName']?.toString(),
      positionLabel: json['positionLabel']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      urgencyLevel: json['urgencyLevel']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      description: json['description']?.toString(),
      photoUrls: (json['photoUrls'] as List? ?? [])
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .map((e) => e.startsWith('http') ? e : 'https://api.solimus.sn/api/files/$e')
          .toList(),
      declaredByName: json['declaredByName']?.toString(),
      closingNote: json['closingNote']?.toString(),
      history: hList.map((e) => TenantSignalementHistoryItem.fromJson(e as Map<String, dynamic>)).toList(),
      fromTenant: json['fromTenant'] as bool? ?? true,
      tenantName: json['tenantName']?.toString(),
    );
  }
}

// ─── Signalement UI Legacy ───────────────────────────────────────────────────

class SignalementLocataire {
  final String id;
  final String titre;
  final String description;
  final DateTime date;
  final SignalementPriorite priorite;
  final SignalementStatut statut;
  final List<String> photoUrls;

  const SignalementLocataire({
    required this.id,
    required this.titre,
    required this.description,
    required this.date,
    required this.priorite,
    required this.statut,
    this.photoUrls = const [],
  });

  factory SignalementLocataire.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt']?.toString() ?? json['date']?.toString();
    return SignalementLocataire(
      id: json['id']?.toString() ?? '',
      titre: json['title']?.toString() ?? json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? json['positionLabel']?.toString() ?? '',
      date: rawDate != null
          ? DateTime.tryParse(rawDate) ?? DateTime.now()
          : DateTime.now(),
      priorite: _parsePriorite(json['urgencyLevel']?.toString() ?? json['priorite']?.toString() ?? 'moyenne'),
      statut: _parseStatut(json['status']?.toString() ?? json['statut']?.toString() ?? 'en_attente'),
      photoUrls: (json['photoUrls'] as List? ?? [])
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .map((e) => e.startsWith('http') ? e : 'https://api.solimus.sn/api/files/$e')
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'description': description,
        'date': date.toIso8601String(),
        'priorite': priorite.name,
        'statut': statut.name,
        'photoUrls': photoUrls,
      };

  static SignalementPriorite _parsePriorite(String s) {
    switch (s.toUpperCase()) {
      case 'HAUTE':
      case 'URGENT':
        return SignalementPriorite.haute;
      case 'FAIBLE':
        return SignalementPriorite.faible;
      default:
        return SignalementPriorite.moyenne;
    }
  }

  static SignalementStatut _parseStatut(String s) {
    switch (s.toUpperCase()) {
      case 'IN_PROGRESS':
      case 'EN_COURS':
      case 'ENCOURS':
        return SignalementStatut.enCours;
      case 'RESOLVED':
      case 'CONVERTED_TO_WORK':
      case 'RESOLU':
      case 'RÉSOLU':
        return SignalementStatut.resolu;
      default:
        return SignalementStatut.enAttente;
    }
  }
}

// ─── Travaux ──────────────────────────────────────────────────────────────────

class TravauxLocataire {
  final String id;
  final String titre;
  final String description;
  final DateTime? datePrevue;
  final TravauxStatut statut;
  final TravauxCategorie categorie;
  final String entreprise;

  const TravauxLocataire({
    required this.id,
    required this.titre,
    required this.description,
    this.datePrevue,
    required this.statut,
    required this.categorie,
    required this.entreprise,
  });

  factory TravauxLocataire.fromJson(Map<String, dynamic> json) {
    return TravauxLocataire(
      id: json['id'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      datePrevue: json['datePrevue'] != null
          ? DateTime.tryParse(json['datePrevue'] as String)
          : null,
      statut: _parseStatut(json['statut'] as String? ?? 'planifie'),
      categorie: _parseCategorie(json['categorie'] as String? ?? 'autre'),
      entreprise: json['entreprise'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'description': description,
        'datePrevue': datePrevue?.toIso8601String(),
        'statut': statut.name,
        'categorie': categorie.name,
        'entreprise': entreprise,
      };

  static TravauxStatut _parseStatut(String s) {
    switch (s.toLowerCase()) {
      case 'en_cours':
      case 'encours':
        return TravauxStatut.enCours;
      case 'termine':
      case 'terminé':
        return TravauxStatut.termine;
      case 'annule':
      case 'annulé':
        return TravauxStatut.annule;
      default:
        return TravauxStatut.planifie;
    }
  }

  static TravauxCategorie _parseCategorie(String s) {
    switch (s.toLowerCase()) {
      case 'plomberie':
        return TravauxCategorie.plomberie;
      case 'peinture':
        return TravauxCategorie.peinture;
      case 'electricite':
      case 'électricité':
        return TravauxCategorie.electricite;
      case 'entretien':
        return TravauxCategorie.entretien;
      default:
        return TravauxCategorie.autre;
    }
  }
}
