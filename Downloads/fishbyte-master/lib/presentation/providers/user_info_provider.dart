import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que se encarga de devolver un Future con la info del usuario
/// Ahora utiliza los datos guardados por AuthRepository (Supabase) en vez de GraphQL
final userInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  // Leer los datos de usuario desde SharedPreferences (guardados durante el login con Supabase)
  final userDataString = prefs.getString('userData');
  final enterpriseDataString = prefs.getString('enterpriseData');
  final centersDataString = prefs.getString('centersData');

  // Parsear los datos JSON
  Map<String, dynamic>? userData =
      userDataString != null ? jsonDecode(userDataString) : null;
  Map<String, dynamic>? enterpriseData = 
      enterpriseDataString != null ? jsonDecode(enterpriseDataString) : null;
  List<dynamic>? centersData =
      centersDataString != null ? jsonDecode(centersDataString) : null;

  // Obtener los datos necesarios
  String? username = userData?['name'] ?? userData?['email']; // Nombre de usuario o email si no hay nombre
  String? roleName = userData?['role']; // Rol del usuario
  String? enterpriseName = enterpriseData?['name']; // Nombre de la empresa

  // Si no tenemos nombre de empresa pero tenemos centros, intentar obtenerlo del primer centro
  if (enterpriseName == null && centersData != null && centersData.isNotEmpty) {
    final firstCenter = centersData[0];
    final centerEnterpriseId = firstCenter['enterprise_id'];
    
    // Si el centro tiene ID de empresa pero no tenemos datos de empresa,
    // usamos "Empresa no especificada" como fallback
    if (centerEnterpriseId != null) {
      enterpriseName = "Empresa no especificada";
    }
  }

  return {
    'username': username,
    'roleName': roleName,
    'enterpriseName': enterpriseName,
  };
});
