import 'package:fishbyte/infrastructure/models/cage_model.dart';

// Modelo actualizado para la estructura de datos de Supabase
class CenterModel {
  final String id;         
  final String name;
  final String category;
  final String species;
  final String ACS;
  final String SIEP;
  final String water;
  final String enterpriseName; // Nombre de la empresa (si está disponible)
  final List<CageModel> cages;

  CenterModel({
    required this.id,
    required this.name,
    required this.category,
    required this.species,
    required this.ACS,
    required this.SIEP,
    required this.water,
    required this.enterpriseName,
    required this.cages,
  });

  // Fábrica actualizada para el formato de Supabase
  factory CenterModel.fromJson(Map<String, dynamic> json) {
    // Verificar si los datos están en formato antiguo (GraphQL) o nuevo (Supabase)
    bool isOldFormat = json.containsKey('attributes');

    if (isOldFormat) {
      // Formato antiguo (GraphQL)
      final attrs = json['attributes'];
      final enterpriseData = attrs['enterprise']['data'];
      final enterpriseAttrs = enterpriseData != null ? enterpriseData['attributes'] : null;

      // Lista de jaulas (formato antiguo)
      final cagesData = attrs['cages'] != null ? 
                       (attrs['cages']['data'] as List<dynamic>) : 
                       <dynamic>[];

      return CenterModel(
        id: json['id'],
        name: attrs['name'] ?? '',
        category: attrs['category'] ?? '',
        species: attrs['species'] ?? '',
        ACS: attrs['ACS'] ?? '',
        SIEP: attrs['SIEP'] ?? '',
        water: attrs['water'] ?? '',
        enterpriseName: enterpriseAttrs != null ? enterpriseAttrs['name'] ?? '' : '',
        cages: cagesData.map((c) => CageModel.fromJson(c)).toList(),
      );
    } else {
      // Formato nuevo (Supabase)
      // Intentamos obtener el nombre de la empresa desde los metadatos o usamos un valor por defecto
      String enterpriseName = '';
      
      // Buscar el ID de la empresa en el JSON si existe
      final enterpriseId = json['enterprise_id'];
      
      // Cargar jaulas del formato Supabase
      List<CageModel> cages = [];
      if (json['cages'] != null && json['cages'] is List) {
        cages = (json['cages'] as List).map((c) => CageModel.fromJson(c)).toList();
      }

      return CenterModel(
        id: json['id'] ?? '0',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        species: json['species'] ?? '',
        ACS: json['acs'] ?? '', // Nótese el cambio de ACS a acs en Supabase
        SIEP: json['siep'] ?? '', // Nótese el cambio de SIEP a siep en Supabase
        water: json['water'] ?? '',
        enterpriseName: enterpriseName,
        cages: cages,
      );
    }
  }
}
