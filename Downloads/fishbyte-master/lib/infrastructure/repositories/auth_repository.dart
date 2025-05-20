// lib/infrastructure/repositories/auth_repository.dart
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fishbyte/infrastructure/datasources/supabase_types.dart' as app_types;

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Método para iniciar sesión con Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
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
      
      // Obtener datos de la empresa asociada al usuario
      final enterpriseId = userData['enterprise_id'];
      Map<String, dynamic>? enterpriseData;
      List<dynamic>? centersData;
      
      if (enterpriseId != null) {
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
