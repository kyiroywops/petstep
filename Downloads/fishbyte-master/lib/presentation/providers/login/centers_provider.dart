import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:fishbyte/infrastructure/models/center_model.dart';

final centersProvider = FutureProvider<List<Center>>((ref) async {
  final url = 'https://storage.googleapis.com/pathovet-test/enterprises.json';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Decodifica la respuesta como UTF-8 para mostrar correctamente las tildes y caracteres especiales
    final decodedBody = utf8.decode(response.bodyBytes);
    final List<dynamic> data = json.decode(decodedBody);
    return data.map((e) => Center.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load centers');
  }
});

// Provider para almacenar el objeto Center seleccionado
final selectedCenterProvider = StateProvider<Center?>((ref) => null);

// Providers adicionales para almacenar label y value por separado, estos se usan para el login
final selectedCenterLabelProvider = StateProvider<String?>((ref) => null);
final selectedCenterValueProvider = StateProvider<String?>((ref) => null);
