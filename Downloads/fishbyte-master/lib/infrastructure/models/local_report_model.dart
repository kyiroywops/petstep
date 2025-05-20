class LocalReport {
  final String idGlobal;
  
  // Centro
  final int centerId;
  final String centerName;
  final String centerACS;
  final String centerSIEP;
  final String centerWater;
  final String centerCategory;
  final String centerSpecies;

  // Jaula
  final int cageId;
  final String cageName;

  // Información adicional
  final double weight;
  final bool subido;

  // === NUEVOS CAMPOS ===
  final String name;       // Por si el backend pide "name"
  final DateTime shoot;    // O String date si prefieres
  final int enterprise;    // enterprise ID
  final int user;          // user ID

  LocalReport({
    required this.idGlobal,
    required this.centerId,
    required this.centerName,
    required this.centerACS,
    required this.centerSIEP,
    required this.centerWater,
    required this.centerCategory,
    required this.centerSpecies,
    required this.cageId,
    required this.cageName,
    required this.weight,
    required this.subido,
    
    // Nuevos campos
    required this.name,
    required this.shoot,
    required this.enterprise,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'idGlobal': idGlobal,
      'centerId': centerId,
      'centerName': centerName,
      'centerACS': centerACS,
      'centerSIEP': centerSIEP,
      'centerWater': centerWater,
      'centerCategory': centerCategory,
      'centerSpecies': centerSpecies,
      'cageId': cageId,
      'cageName': cageName,
      'weight': weight,
      'subido': subido ? 1 : 0,
      // Nuevos:
      'name': name,
      'shoot': shoot.toIso8601String(), // si quieres guardar como String en DB
      'enterprise': enterprise,
      'user': user,
    };
  }

  factory LocalReport.fromMap(Map<String, dynamic> map) {
    return LocalReport(
      idGlobal: map['idGlobal'],
      centerId: map['centerId'] ?? 0,
      centerName: map['centerName'] ?? '',
      centerACS: map['centerACS'] ?? '',
      centerSIEP: map['centerSIEP'] ?? '',
      centerWater: map['centerWater'] ?? '',
      centerCategory: map['centerCategory'] ?? '',
      centerSpecies: map['centerSpecies'] ?? '',
      cageId: map['cageId'] ?? 0,
      cageName: map['cageName'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      subido: (map['subido'] ?? 0) == 1,

      // Nuevos
      name: map['name'] ?? '',
      shoot: DateTime.tryParse(map['shoot'] ?? '') ?? DateTime.now(),
      enterprise: map['enterprise'] ?? 0,
      user: map['user'] ?? 0,
    );
  }

  LocalReport copyWith({
    String? idGlobal,
    int? centerId,
    String? centerName,
    String? centerACS,
    String? centerSIEP,
    String? centerWater,
    String? centerCategory,
    String? centerSpecies,
    int? cageId,
    String? cageName,
    double? weight,
    bool? subido,

    // nuevos
    String? name,
    DateTime? shoot,
    int? enterprise,
    int? user,
  }) {
    return LocalReport(
      idGlobal: idGlobal ?? this.idGlobal,
      centerId: centerId ?? this.centerId,
      centerName: centerName ?? this.centerName,
      centerACS: centerACS ?? this.centerACS,
      centerSIEP: centerSIEP ?? this.centerSIEP,
      centerWater: centerWater ?? this.centerWater,
      centerCategory: centerCategory ?? this.centerCategory,
      centerSpecies: centerSpecies ?? this.centerSpecies,
      cageId: cageId ?? this.cageId,
      cageName: cageName ?? this.cageName,
      weight: weight ?? this.weight,
      subido: subido ?? this.subido,

      name: name ?? this.name,
      shoot: shoot ?? this.shoot,
      enterprise: enterprise ?? this.enterprise,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return '''
LocalReport(
  idGlobal: $idGlobal,
  centerId: $centerId,
  centerName: $centerName,
  centerACS: $centerACS,
  centerSIEP: $centerSIEP,
  centerWater: $centerWater,
  centerCategory: $centerCategory,
  centerSpecies: $centerSpecies,
  cageId: $cageId,
  cageName: $cageName,
  weight: $weight,
  subido: $subido,
  name: $name,
  shoot: $shoot,
  enterprise: $enterprise,
  user: $user
)
''';
  }
}
