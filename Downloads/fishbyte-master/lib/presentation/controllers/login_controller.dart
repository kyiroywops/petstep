import 'package:fishbyte/presentation/providers/login/centers_provider.dart';
import 'package:fishbyte/presentation/providers/login/auth_provider.dart';
import 'package:fishbyte/presentation/providers/user_info_provider.dart';
import 'package:fishbyte/presentation/providers/upload_queue_provider.dart';
import 'package:fishbyte/main.dart';  // Importar para acceder a las constantes

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;

class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;
  final _supabase = Supabase.instance.client;
  String? _selectedEnterpriseId; // Guardar la empresa seleccionada

  // Método para obtener todas las empresas disponibles
  Future<List<Map<String, dynamic>>> getAllEnterprises() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      return await authRepository.getAllEnterprises();
    } catch (e) {
      debugPrint("Error obteniendo empresas: $e");
      throw Exception("Error al obtener las empresas: $e");
    }
  }

  // Procesar el inicio de sesión exitoso con empresa específica
  Future<void> _processSignIn(String enterpriseId) async {
    try {
      state = const AsyncValue.loading();
      
      debugPrint("Procesando inicio de sesión: usuario autenticado con éxito para empresa $enterpriseId");
      
      // Obtener el repositorio de autenticación
      final authRepository = ref.read(authRepositoryProvider);
      
      // Procesar los datos del usuario con la empresa específica
      final userData = await authRepository.loginWithGoogle(enterpriseId);
      
      debugPrint("Datos de usuario obtenidos con éxito: ${userData['userData']['email']}");
      
      // ✅ IMPORTANTE: Invalidar providers para que se recarguen con los nuevos datos
      ref.invalidate(userInfoProvider);
      debugPrint("✅ Providers invalidados - datos de usuario actualizados");
      
      // 🧹 IMPORTANTE: Limpiar la cola de subida para evitar conflictos con reportes de empresas anteriores
      ref.read(uploadQueueProvider.notifier).clearAll();
      debugPrint("🧹 Cola de subida limpiada - evitando conflictos entre empresas");
      
      // Éxito
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint("Error procesando inicio de sesión: $e");
      state = AsyncValue.error(e, st);
    }
  }

  // Método para iniciar sesión con Google y empresa específica
  // Este método se llama desde la pantalla de login
  Future<void> signInWithGoogle(String enterpriseId) async {
    print("==== FISHBYTE DEBUG INICIO ====");
    print("Método signInWithGoogle llamado");
    print("Empresa ID: $enterpriseId");
    print("Platform.isAndroid: ${Platform.isAndroid}");
    print("kGoogleWebClientId: $kGoogleWebClientId");
    print("================================");
    
    try {
      state = const AsyncValue.loading();
      
      // Guardar la empresa seleccionada
      _selectedEnterpriseId = enterpriseId;
      
      print("Configurando GoogleSignIn...");
      // Inicializar GoogleSignIn con los IDs de cliente configurados
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // En iOS utilizamos el kGoogleIOSClientId específico
        clientId: !kIsWeb && Platform.isIOS ? kGoogleIOSClientId : null,
        serverClientId: kGoogleWebClientId,
      );
      
      print("GoogleSignIn configurado correctamente");
      
      debugPrint("🔧 GoogleSignIn configurado:");
      debugPrint("   - clientId: ${!kIsWeb && Platform.isIOS ? kGoogleIOSClientId : 'null (Android usa google-services.json)'}");
      debugPrint("   - serverClientId: $kGoogleWebClientId");
      
      // Iniciar el flujo de autenticación con Google
      print("INICIANDO googleSignIn.signIn()...");
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint("❌ Usuario canceló el proceso de sign-in");
        throw Exception("Proceso de inicio de sesión con Google cancelado");
      }
      
      debugPrint("✅ GoogleUser obtenido:");
      debugPrint("   - email: ${googleUser.email}");
      debugPrint("   - displayName: ${googleUser.displayName}");
      debugPrint("   - id: ${googleUser.id}");
      
      // Obtener los tokens de autenticación
      debugPrint("🔑 Obteniendo tokens de autenticación...");
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      
      debugPrint("🔑 Token obtenido:");
      debugPrint("   - idToken: ${idToken?.substring(0, 20)}...");
      
      if (idToken == null) {
        debugPrint("❌ No se obtuvo idToken");
        throw Exception("No se obtuvo el token de ID de Google");
      }
      
      debugPrint("✅ Token obtenido correctamente");
      
      // Iniciar sesión en Supabase con el token de ID de Google
      // En las versiones nuevas de google_sign_in, ya no necesitamos accessToken
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      
      debugPrint("Proceso de autenticación con Google completado con éxito");
      
      // Ahora procesar los datos del usuario con la empresa seleccionada
      await _processSignIn(enterpriseId);
      
    } catch (e, st) {
      debugPrint("Error iniciando sesión con Google: ${e.toString()}");
      
      // Información adicional de depuración
      if (e is AuthException) {
        debugPrint("Código de error: ${e.statusCode}");
        debugPrint("Mensaje de error: ${e.message}");
      }
      
      // Actualizar el estado para mostrar el error al usuario
      state = AsyncValue.error("Error iniciando sesión con Google: ${e.toString()}", st);
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      state = const AsyncValue.loading();
      
      debugPrint("Cerrando sesión...");
      
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.logout();
      
      debugPrint("Sesión cerrada con éxito");
      
      // ✅ IMPORTANTE: Invalidar providers para limpiar datos del usuario anterior
      ref.invalidate(userInfoProvider);
      debugPrint("✅ Providers invalidados - datos de usuario limpiados");
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint("Error durante logout: $e");
      state = AsyncValue.error(e, st);
    }
  }

  // Método para verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final authRepository = ref.read(authRepositoryProvider);
    final isAuth = await authRepository.isAuthenticated();
    debugPrint("¿Usuario autenticado? ${isAuth ? 'Sí' : 'No'}");
    return isAuth;
  }
}

// Provider del LoginController
final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
  return LoginController(ref);
});
