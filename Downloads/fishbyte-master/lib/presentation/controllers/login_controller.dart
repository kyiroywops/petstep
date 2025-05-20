import 'package:fishbyte/presentation/providers/login/centers_provider.dart';
import 'package:fishbyte/presentation/providers/login/auth_provider.dart';
import 'package:fishbyte/main.dart';  // Importar para acceder a las constantes

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;

class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController(this.ref) : super(const AsyncValue.data(null)) {
    // Escuchar cambios en la autenticación
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      debugPrint("Auth event: $event");
      debugPrint("Auth session: ${_supabase.auth.currentSession?.user.email ?? 'No session'}");
      if (event == AuthChangeEvent.signedIn) {
        // El usuario ha iniciado sesión, obtener y guardar sus datos
        _processSignIn();
      }
    });
  }

  final Ref ref;
  final _supabase = Supabase.instance.client;

  // Procesar el inicio de sesión exitoso
  Future<void> _processSignIn() async {
    try {
      state = const AsyncValue.loading();
      
      debugPrint("Procesando inicio de sesión: usuario autenticado con éxito");
      
      // Obtener el repositorio de autenticación
      final authRepository = ref.read(authRepositoryProvider);
      
      // Procesar los datos del usuario
      final userData = await authRepository.loginWithGoogle();
      
      debugPrint("Datos de usuario obtenidos con éxito: ${userData['userData']['email']}");
      
      // Éxito
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint("Error procesando inicio de sesión: $e");
      state = AsyncValue.error(e, st);
    }
  }

  // Método para iniciar sesión con Google
  // Este método se llama desde la pantalla de login
  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      
      debugPrint("Iniciando proceso de autenticación nativa con Google...");
      
      // Inicializar GoogleSignIn con los IDs de cliente configurados
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // En iOS utilizamos el kGoogleIOSClientId específico
        clientId: !kIsWeb && Platform.isIOS ? kGoogleIOSClientId : null,
        serverClientId: kGoogleWebClientId,
      );
      
      // Iniciar el flujo de autenticación con Google
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception("Proceso de inicio de sesión con Google cancelado");
      }
      
      // Obtener los tokens de autenticación
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null) {
        throw Exception("No se obtuvo el token de acceso de Google");
      }
      if (idToken == null) {
        throw Exception("No se obtuvo el token de ID de Google");
      }
      
      debugPrint("Tokens de Google obtenidos correctamente");
      
      // Iniciar sesión en Supabase con el token de ID de Google
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      debugPrint("Proceso de autenticación con Google completado con éxito");
      
      // El listener de onAuthStateChange procesará la sesión y actualizará el estado
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
