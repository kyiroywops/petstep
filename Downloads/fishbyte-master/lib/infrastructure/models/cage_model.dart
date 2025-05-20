// este se usa para el show bottom sheet solamente para seleccionar que cage se esta seleciconando

class CageModel {
  final String id;
  final String name;

  CageModel({
    required this.id,
    required this.name,
  });

  /// Parseamos algo como:
  /// {
  ///   "id": "10",
  ///   "attributes": {
  ///     "name": "111"
  ///   }
  /// }
  factory CageModel.fromJson(Map<String, dynamic> json) {
    // Verificar si los datos están en formato antiguo (GraphQL) o nuevo (Supabase)
    bool isOldFormat = json.containsKey('attributes');

    if (isOldFormat) {
      // Formato antiguo (GraphQL)
      return CageModel(
        id: json['id'], // es un String en tu JSON
        name: json['attributes']['name'] ?? '',
      );
    } else {
      // Formato nuevo (Supabase)
      return CageModel(
        id: json['id'] ?? '', 
        name: json['name'] ?? '',
      );
    }
  }
}
