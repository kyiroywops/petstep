// Definición de tipos para trabajar con Supabase
// Generados a partir del esquema de la base de datos

import 'dart:convert';

// Tipo genérico para manejar JSON
typedef Json = Map<String, dynamic>;

// Enumeraciones
enum CategoryEnum { postSmolt, adulto, smolt, alevin, ova }
enum SeaEnum { marina, estuarina, dulce }
enum SpeciesEnum { salmonAtlantico, truchaArcoiris, salmonCoho }
enum UserRoleEnum { chief, vet, worker, authenticated, blocked }

// Extensiones para convertir entre String y Enum
extension CategoryEnumExtension on CategoryEnum {
  String toStr() {
    switch (this) {
      case CategoryEnum.postSmolt: return 'Post Smolt';
      case CategoryEnum.adulto: return 'Adulto';
      case CategoryEnum.smolt: return 'Smolt';
      case CategoryEnum.alevin: return 'Alevin';
      case CategoryEnum.ova: return 'Ova';
    }
  }
  
  static CategoryEnum? fromStr(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'Post Smolt': return CategoryEnum.postSmolt;
      case 'Adulto': return CategoryEnum.adulto;
      case 'Smolt': return CategoryEnum.smolt;
      case 'Alevin': return CategoryEnum.alevin;
      case 'Ova': return CategoryEnum.ova;
      default: return null;
    }
  }
}

extension SeaEnumExtension on SeaEnum {
  String toStr() {
    switch (this) {
      case SeaEnum.marina: return 'Marina';
      case SeaEnum.estuarina: return 'Estuarina';
      case SeaEnum.dulce: return 'Dulce';
    }
  }
  
  static SeaEnum? fromStr(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'Marina': return SeaEnum.marina;
      case 'Estuarina': return SeaEnum.estuarina;
      case 'Dulce': return SeaEnum.dulce;
      default: return null;
    }
  }
}

extension SpeciesEnumExtension on SpeciesEnum {
  String toStr() {
    switch (this) {
      case SpeciesEnum.salmonAtlantico: return 'Salmon Atlantico';
      case SpeciesEnum.truchaArcoiris: return 'Trucha Arcoiris';
      case SpeciesEnum.salmonCoho: return 'Salmon Coho';
    }
  }
  
  static SpeciesEnum? fromStr(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'Salmon Atlantico': return SpeciesEnum.salmonAtlantico;
      case 'Trucha Arcoiris': return SpeciesEnum.truchaArcoiris;
      case 'Salmon Coho': return SpeciesEnum.salmonCoho;
      default: return null;
    }
  }
}

extension UserRoleEnumExtension on UserRoleEnum {
  String toStr() {
    switch (this) {
      case UserRoleEnum.chief: return 'Chief';
      case UserRoleEnum.vet: return 'Vet';
      case UserRoleEnum.worker: return 'Worker';
      case UserRoleEnum.authenticated: return 'Authenticated';
      case UserRoleEnum.blocked: return 'Blocked';
    }
  }
  
  static UserRoleEnum? fromStr(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'Chief': return UserRoleEnum.chief;
      case 'Vet': return UserRoleEnum.vet;
      case 'Worker': return UserRoleEnum.worker;
      case 'Authenticated': return UserRoleEnum.authenticated;
      case 'Blocked': return UserRoleEnum.blocked;
      default: return null;
    }
  }
}

// Modelos para las tablas
class User {
  final String userId;
  final String? email;
  final String? displayName;
  final String? enterpriseId;
  final UserRoleEnum? role;
  final String? blockReason;
  final bool? hasPassword;
  final int? signInCount;
  final String? verificationPassword;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSignIn;

  User({
    required this.userId,
    this.email,
    this.displayName,
    this.enterpriseId,
    this.role,
    this.blockReason,
    this.hasPassword,
    this.signInCount,
    this.verificationPassword,
    this.createdAt,
    this.updatedAt,
    this.lastSignIn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      email: json['email'],
      displayName: json['display_name'],
      enterpriseId: json['enterprise_id'],
      role: UserRoleEnumExtension.fromStr(json['role']),
      blockReason: json['block_reason'],
      hasPassword: json['has_password'],
      signInCount: json['sign_in_count'],
      verificationPassword: json['verification_password'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      lastSignIn: json['last_sign_in'] != null ? DateTime.parse(json['last_sign_in']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'enterprise_id': enterpriseId,
      'role': role?.toStr(),
      'block_reason': blockReason,
      'has_password': hasPassword,
      'sign_in_count': signInCount,
      'verification_password': verificationPassword,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_sign_in': lastSignIn?.toIso8601String(),
    };
  }
}

class Enterprise {
  final String id;
  final String name;
  final String? nickname;
  final DateTime? createdAt;

  Enterprise({
    required this.id,
    required this.name,
    this.nickname,
    this.createdAt,
  });

  factory Enterprise.fromJson(Map<String, dynamic> json) {
    return Enterprise(
      id: json['id'],
      name: json['name'],
      nickname: json['nickname'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Center {
  final String id;
  final String name;
  final String? enterpriseId;
  final String? acs;
  final String? siep;
  final CategoryEnum? category;
  final SpeciesEnum? species;
  final SeaEnum? water;
  final Json? metadata;
  final DateTime? createdAt;

  Center({
    required this.id,
    required this.name,
    this.enterpriseId,
    this.acs,
    this.siep,
    this.category,
    this.species,
    this.water,
    this.metadata,
    this.createdAt,
  });

  factory Center.fromJson(Map<String, dynamic> json) {
    return Center(
      id: json['id'],
      name: json['name'],
      enterpriseId: json['enterprise_id'],
      acs: json['acs'],
      siep: json['siep'],
      category: CategoryEnumExtension.fromStr(json['category']),
      species: SpeciesEnumExtension.fromStr(json['species']),
      water: SeaEnumExtension.fromStr(json['water']),
      metadata: json['metadata'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'enterprise_id': enterpriseId,
      'acs': acs,
      'siep': siep,
      'category': category?.toStr(),
      'species': species?.toStr(),
      'water': water?.toStr(),
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Cage {
  final String id;
  final String name;
  final String? code;
  final String? centerId;
  final String? enterpriseId;
  final Json? metadata;
  final DateTime? createdAt;

  Cage({
    required this.id,
    required this.name,
    this.code,
    this.centerId,
    this.enterpriseId,
    this.metadata,
    this.createdAt,
  });

  factory Cage.fromJson(Map<String, dynamic> json) {
    return Cage(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      centerId: json['center_id'],
      enterpriseId: json['enterprise_id'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'center_id': centerId,
      'enterprise_id': enterpriseId,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Report {
  final String id;
  final String? userId;
  final String? centerId;
  final String? cageId;
  final String? enterpriseId;
  final String? idglobal;
  final String? shoot;
  final double? weight;
  final bool? pcr;
  final bool? aiApproved;
  final bool? revisado;
  final Json? disease;
  final Json? diseaseAi;
  final Json? check;
  final Json? comment;
  final Json? labels;
  final Json? metadata;
  final DateTime? createdAt;

  Report({
    required this.id,
    this.userId,
    this.centerId,
    this.cageId,
    this.enterpriseId,
    this.idglobal,
    this.shoot,
    this.weight,
    this.pcr,
    this.aiApproved,
    this.revisado,
    this.disease,
    this.diseaseAi,
    this.check,
    this.comment,
    this.labels,
    this.metadata,
    this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      userId: json['user_id'],
      centerId: json['center_id'],
      cageId: json['cage_id'],
      enterpriseId: json['enterprise_id'],
      idglobal: json['idglobal'],
      shoot: json['shoot'],
      weight: json['weight'] != null ? json['weight'].toDouble() : null,
      pcr: json['pcr'],
      aiApproved: json['ai_approved'],
      revisado: json['revisado'],
      disease: json['disease'],
      diseaseAi: json['disease_ai'],
      check: json['check'],
      comment: json['comment'],
      labels: json['labels'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'center_id': centerId,
      'cage_id': cageId,
      'enterprise_id': enterpriseId,
      'idglobal': idglobal,
      'shoot': shoot,
      'weight': weight,
      'pcr': pcr,
      'ai_approved': aiApproved,
      'revisado': revisado,
      'disease': disease,
      'disease_ai': diseaseAi,
      'check': check,
      'comment': comment,
      'labels': labels,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Image {
  final String id;
  final String storagePath;
  final String? reportId;
  final String? description;
  final Json? metadata;
  final DateTime? createdAt;

  Image({
    required this.id,
    required this.storagePath,
    this.reportId,
    this.description,
    this.metadata,
    this.createdAt,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id'],
      storagePath: json['storage_path'],
      reportId: json['report_id'],
      description: json['description'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storage_path': storagePath,
      'report_id': reportId,
      'description': description,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }
} 