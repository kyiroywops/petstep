// lib/infrastructure/repositories/auth_repository.dart
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fishbyte/infrastructure/datasources/supabase_types.dart' as app_types;

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Método para obtener todas las empresas disponibles
  // Nota: Se obtienen todas las empresas porque el filtrado se hace en el momento del login
  Future<List<Map<String, dynamic>>> getAllEnterprises() async {
    try {
      print("🔍 Obteniendo todas las empresas disponibles...");
      
      final response = await _supabase
          .from('enterprises')
          .select('id, name, nickname')
          .order('name');
      
      print("✅ Empresas obtenidas: ${response.length}");
      for (final enterprise in response) {
        print("  - ${enterprise['name']} (${enterprise['id']})");
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error obteniendo empresas: $e");
      throw Exception("Error al obtener las empresas: $e");
    }
  }

  // Método para obtener solo las empresas a las que un usuario específico tiene acceso
  Future<List<Map<String, dynamic>>> getEnterprisesForUser(String userEmail) async {
    try {
      print("🔍 Obteniendo empresas para usuario: $userEmail");
      
      // Obtener información del usuario para ver sus empresas
      final userResponse = await _supabase
          .from('users')
          .select('enterprises_id, enterprise_id')
          .eq('email', userEmail)
          .maybeSingle();
      
      print("👤 Datos del usuario: $userResponse");
      
      if (userResponse == null) {
        print("❌ Usuario no encontrado");
        return [];
      }
      
      // Obtener IDs de empresas del usuario
      Set<String> userEnterpriseIds = {};
      
      // Agregar enterprise_id si existe
      if (userResponse['enterprise_id'] != null) {
        userEnterpriseIds.add(userResponse['enterprise_id'].toString());
        print("✅ Agregando enterprise_id: ${userResponse['enterprise_id']}");
      }
      
      // Agregar enterprises_id si existe (array)
      if (userResponse['enterprises_id'] != null) {
        final enterprisesArray = userResponse['enterprises_id'] as List<dynamic>;
        for (final id in enterprisesArray) {
          userEnterpriseIds.add(id.toString());
          print("✅ Agregando enterprises_id: $id");
        }
      }
      
      if (userEnterpriseIds.isEmpty) {
        print("❌ Usuario no tiene empresas asignadas");
        return [];
      }
      
      print("🏢 Total de empresas del usuario: ${userEnterpriseIds.length}");
      print("🏢 IDs de empresas: $userEnterpriseIds");
      
      // Obtener información de las empresas a las que tiene acceso
      final response = await _supabase
          .from('enterprises')
          .select('id, name, nickname')
          .inFilter('id', userEnterpriseIds.toList())
          .order('name');
      
      print("✅ Empresas obtenidas para usuario: ${response.length}");
      for (final enterprise in response) {
        print("  - ${enterprise['name']} (${enterprise['id']})");
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error obteniendo empresas para usuario: $e");
      throw Exception("Error al obtener las empresas: $e");
    }
  }

  // Método para verificar si un usuario tiene acceso a una empresa específica
  Future<bool> userHasAccessToEnterprise(String userEmail, String enterpriseId) async {
    try {
      print("🔍 Verificando acceso para usuario: $userEmail, empresa: $enterpriseId");
      
      // Primero verificar si el usuario existe en la base de datos
      final userResponse = await _supabase
          .from('users')
          .select('user_id, enterprise_id, enterprises_id')
          .eq('email', userEmail)
          .maybeSingle();
      
      print("👤 Respuesta usuario: $userResponse");
      
      if (userResponse == null) {
        print("❌ Usuario no encontrado en la base de datos");
        return false;
      }
      
      final userId = userResponse['user_id'];
      print("✅ Usuario encontrado: $userId");
      
      // Verificar si el usuario tiene enterprise_id directamente en la tabla users
      if (userResponse['enterprise_id'] != null) {
        final userEnterpriseId = userResponse['enterprise_id'].toString();
        print("🏢 Usuario tiene enterprise_id directo: $userEnterpriseId");
        if (userEnterpriseId == enterpriseId) {
          print("✅ Acceso concedido por enterprise_id directo");
          return true;
        }
      }
      
      // También verificar enterprises_id (array de empresas)
      if (userResponse['enterprises_id'] != null) {
        try {
          final enterprisesArray = userResponse['enterprises_id'] as List<dynamic>;
          print("🏢 Usuario tiene enterprises_id (array): $enterprisesArray");
          
          // Verificar si la empresa seleccionada está en el array
          for (final id in enterprisesArray) {
            if (id.toString() == enterpriseId) {
              print("✅ Acceso concedido por enterprises_id (encontrado en array)");
              return true;
            }
          }
          print("❌ Empresa $enterpriseId no encontrada en el array enterprises_id");
        } catch (e) {
          print("⚠️ Error procesando enterprises_id como array: $e");
          // Fallback: intentar como string
          final userEnterpriseId = userResponse['enterprises_id'].toString();
          print("🏢 Usuario tiene enterprises_id (string): $userEnterpriseId");
          if (userEnterpriseId == enterpriseId) {
            print("✅ Acceso concedido por enterprises_id (string)");
            return true;
          }
        }
      }
      
      // Intentar verificar con función RPC si existe
      try {
        print("🔄 Intentando usar función RPC get_user_enterprise_id...");
        final rpcResult = await _supabase.rpc('get_user_enterprise_id');
        print("📞 Resultado RPC: $rpcResult");
        
        if (rpcResult != null && rpcResult.toString() == enterpriseId) {
          print("✅ Acceso concedido por RPC");
          return true;
        }
      } catch (rpcError) {
        print("⚠️ RPC no disponible: $rpcError");
      }
      
      // Como último recurso, intentar con users_enterprises si existe
      try {
        print("🔄 Intentando consulta en users_enterprises...");
        final userEnterpriseResponse = await _supabase
            .from('users_enterprises')
            .select('id')
            .eq('user_id', userId)
            .eq('enterprise_id', enterpriseId)
            .maybeSingle();
        
        print("🔗 Respuesta users_enterprises: $userEnterpriseResponse");
        return userEnterpriseResponse != null;
      } catch (tableError) {
        print("⚠️ Tabla users_enterprises no existe: $tableError");
      }
      
      print("❌ No se pudo verificar acceso - denegado por defecto");
      return false;
    } catch (e) {
      print("❌ Error verificando acceso a empresa: $e");
      return false;
    }
  }

  // Método para iniciar sesión con Google y empresa específica
  Future<Map<String, dynamic>> loginWithGoogle(String enterpriseId) async {
    try {
      // La autenticación con Google en Supabase se maneja directamente en la UI
      // Este método solo se encarga de procesar los datos de usuario después del inicio de sesión

      // Verificar si hay una sesión activa
      final session = _supabase.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw Exception("No se pudo completar el inicio de sesión");
      }

      // Obtener datos del usuario de Supabase Auth
      final userId = session.user.id;
      
      // Verificar si el usuario ya existe en la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();
      
      // Si el usuario no existe, lo creamos con rol básico
      if (userResponse == null) {
        await _supabase.from('users').insert({
          'user_id': userId,
          'email': session.user.email,
          'display_name': session.user.userMetadata?['full_name'] ?? session.user.email,
          'role': 'Authenticated',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
      // Obtener el usuario (ya existente o recién creado)
      final userData = await _supabase
          .from('users')
          .select('*')
          .eq('user_id', userId)
          .single();
      
      // Usar la empresa específica seleccionada en el login
      Map<String, dynamic>? enterpriseData;
      List<dynamic>? centersData;
      
      // Verificar que el usuario tenga acceso a la empresa seleccionada
      print("🔐 Verificando acceso del usuario ${session.user.email} a la empresa $enterpriseId");
      final hasAccess = await userHasAccessToEnterprise(session.user.email!, enterpriseId);
      print("🔐 Resultado de verificación de acceso: $hasAccess");
      
      if (!hasAccess) {
        throw Exception("No tienes acceso a esta empresa");
      }
      
      print("✅ Acceso verificado correctamente, continuando con el login...");
      
      // Obtener empresa
      enterpriseData = await _supabase
          .from('enterprises')
          .select('*')
          .eq('id', enterpriseId)
          .single();
            
      // Obtener centros
      centersData = await _supabase
          .from('centers')
          .select('*')
          .eq('enterprise_id', enterpriseId)
          .order('name');
          
      // Cargar jaulas para cada centro
      if (centersData != null && centersData.isNotEmpty) {
        // Para cada centro, consultamos sus jaulas
        for (var i = 0; i < centersData.length; i++) {
          final centerId = centersData[i]['id'];
          
          // Consultar jaulas para este centro
          final cagesData = await _supabase
              .from('cages')
              .select('*')
              .eq('center_id', centerId)
              .order('name');
              
          // Añadir las jaulas al objeto de centro
          centersData[i]['cages'] = cagesData;
        }
      }
      
      // Guardar datos en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabaseAccessToken', session.accessToken);
      await prefs.setString('supabaseRefreshToken', session.refreshToken ?? '');
      
      final userDataMap = {
        'id': userId,
        'email': session.user.email,
        'name': userData['display_name'] ?? session.user.userMetadata?['full_name'] ?? '',
        'role': userData['role'],
        'enterprise_id': enterpriseId,
      };
      
      await prefs.setString('userData', jsonEncode(userDataMap));
      
      if (enterpriseData != null) {
        await prefs.setString('enterpriseData', jsonEncode(enterpriseData));
      }
      
      if (centersData != null) {
        await prefs.setString('centersData', jsonEncode(centersData));
      }
      
      // Retornar datos para el controlador
      return {
        'userData': userDataMap,
        'enterpriseData': enterpriseData,
        'centersData': centersData,
      };
    } catch (e) {
      print("Error en AuthRepository.loginWithGoogle: $e");
      throw Exception("Error al iniciar sesión: $e");
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      // Cerrar sesión en Supabase
      await _supabase.auth.signOut();
      
      // Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Eliminar todos los tokens y datos de usuario
      await prefs.remove('supabaseAccessToken');
      await prefs.remove('supabaseRefreshToken');
      await prefs.remove('userData');
      await prefs.remove('enterpriseData');
      await prefs.remove('centersData');
      
      // Limpiar datos adicionales que podrían estar presentes en la app
      await prefs.remove('jwt'); // Token antiguo
      await prefs.remove('enterpriseUrl'); // URL antigua
      await prefs.remove('recentlySentReports'); // Informes recientes
      
      // Si estamos en iOS, hay que limpiar el keychain
      if (_supabase.auth.currentUser != null) {
        // Intentar asegurarnos de que la sesión esté completamente cerrada
        await _supabase.auth.signOut();
      }
      
      print("Sesión cerrada y datos eliminados correctamente");
    } catch (e) {
      print("Error durante logout: $e");
      throw Exception("Error al cerrar sesión: $e");
    }
  }

  // Método para verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final session = _supabase.auth.currentSession;
    return session != null && session.accessToken.isNotEmpty;
  }
  
  // Método para obtener el usuario actual desde Supabase
  Future<app_types.User?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;
      
      final userId = session.user.id;
      final userResponse = await _supabase
          .from('users')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();
          
      if (userResponse == null) return null;
      
      return app_types.User.fromJson(userResponse);
    } catch (e) {
      print("Error en getCurrentUser: $e");
      return null;
    }
  }
  
  // Método para actualizar datos del usuario
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("Usuario no autenticado");
      
      await _supabase
          .from('users')
          .update(userData)
          .eq('user_id', userId);
    } catch (e) {
      print("Error en updateUserProfile: $e");
      throw Exception("Error al actualizar perfil: $e");
    }
  }
}
