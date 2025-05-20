// lib/infrastructure/models/local_report.dart

class LocalReport {
  final String idGlobal;   // UUID global
  final String date;       // Fecha/hora en formato String (ISO 8601 si prefieres)
  final double weight;
  final bool subido;

  final String name;       // "Reporte-<UUID>"
  final String status;     // 'readyToUpload' | 'uploaded'
  final String enterprise;    // ID de la empresa
  final String user;          // ID del usuario
  final String especie;    // Ej. "Salmon Atlántico", etc.

  // Estructura interna de "center"
  final CenterData center;
  // Estructura interna de "cage"
  final CageData cage;
  // Lista de imágenes ({ id, name, img }) que manejas localmente
  final List<ImageItem> imagenes;

  const LocalReport({
    required this.idGlobal,
    required this.date,
    required this.weight,
    required this.subido,
    required this.name,
    required this.status,
    required this.enterprise,
    required this.user,
    required this.especie,
    required this.center,
    required this.cage,
    required this.imagenes,
  });

  // ---------- Métodos JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'idGlobal':    idGlobal,
      'date':        date,
      'weight':      weight,
      'subido':      subido,
      'name':        name,
      'status':      status,
      'enterprise':  enterprise,
      'user':        user,
      'especie':     especie,
      'center':      center.toJson(),
      'cage':        cage.toJson(),
      'imagenes':    imagenes.map((i) => i.toJson()).toList(),
    };
  }

  factory LocalReport.fromJson(Map<String, dynamic> json) {
    return LocalReport(
      idGlobal:    json['idGlobal']   ?? '',
      date:        json['date']       ?? '',
      weight:      (json['weight']    ?? 0.0).toDouble(),
      subido:      json['subido']     ?? false,
      name:        json['name']       ?? '',
      status:      json['status']     ?? 'readyToUpload',
      enterprise: (json['enterprise'] ?? '').toString(),
      user:       (json['user']       ?? '').toString(),
      especie:     json['especie']    ?? '',

      center: CenterData.fromJson(json['center'] ?? {}),
      cage:   CageData.fromJson(json['cage']   ?? {}),

      imagenes: (json['imagenes'] as List<dynamic>? ?? [])
        .map((i) => ImageItem.fromJson(i))
        .toList(),
    );
  }

  // ---------- copyWith ----------
  // Permite actualizar uno o más campos sin recrear manualmente todo.
  LocalReport copyWith({
    String? idGlobal,
    String? date,
    double? weight,
    bool? subido,
    String? name,
    String? status,
    String? enterprise,
    String? user,
    String? especie,
    CenterData? center,
    CageData? cage,
    List<ImageItem>? imagenes,
  }) {
    return LocalReport(
      idGlobal:   idGlobal   ?? this.idGlobal,
      date:       date       ?? this.date,
      weight:     weight     ?? this.weight,
      subido:     subido     ?? this.subido,
      name:       name       ?? this.name,
      status:     status     ?? this.status,
      enterprise: enterprise ?? this.enterprise,
      user:       user       ?? this.user,
      especie:    especie    ?? this.especie,
      center:     center     ?? this.center,
      cage:       cage       ?? this.cage,
      imagenes:   imagenes   ?? this.imagenes,
    );
  }
}

// ======================================================
// CenterData: Estructura del centro {id, name, ACS, ...}
// ======================================================
class CenterData {
  final String id; // Cambiado de int a String para ser compatible con UUIDs de Supabase
  final String name;
  final String ACS;
  final String SIEP;
  final String water;
  final String category;
  final String species;

  const CenterData({
    required this.id,
    required this.name,
    required this.ACS,
    required this.SIEP,
    required this.water,
    required this.category,
    required this.species,
  });

  Map<String, dynamic> toJson() => {
    'id':       id,
    'name':     name,
    'ACS':      ACS,
    'SIEP':     SIEP,
    'water':    water,
    'category': category,
    'species':  species,
  };

  factory CenterData.fromJson(Map<String, dynamic> json) {
    // Manejar el caso donde id puede ser int (antiguo) o String (nuevo)
    String centerId;
    if (json['id'] is int) {
      centerId = json['id'].toString();
    } else {
      centerId = json['id']?.toString() ?? '0';
    }
    
    return CenterData(
      id:       centerId,
      name:     json['name']     ?? '',
      ACS:      json['ACS']      ?? '',
      SIEP:     json['SIEP']     ?? '',
      water:    json['water']    ?? '',
      category: json['category'] ?? '',
      species:  json['species']  ?? '',
    );
  }
}

// ======================================================
// CageData: Estructura de la jaula { id, name }
// ======================================================
class CageData {
  final String id;
  final String name;

  const CageData({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'id':   id,
    'name': name,
  };

  factory CageData.fromJson(Map<String, dynamic> json) {
    return CageData(
      id:   (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
    );
  }
}

// ======================================================
// ImageItem: Estructura para cada imagen local
// ======================================================
class ImageItem {
  final int id;
  final String name;
  final String img; // Ruta local o base64, etc.

  const ImageItem({
    required this.id,
    required this.name,
    required this.img,
  });

  Map<String, dynamic> toJson() => {
    'id':   id,
    'name': name,
    'img':  img,
  };

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id:   json['id']   ?? 0,
      name: json['name'] ?? '',
      img:  json['img']  ?? '',
    );
  }
}
