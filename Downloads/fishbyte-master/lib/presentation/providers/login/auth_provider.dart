import 'package:fishbyte/infrastructure/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Proveedor para acceder al cliente de Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Proveedor para el repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepository(supabaseClient);
});

// Proveedor que indica si el usuario está autenticado
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.isAuthenticated();
});

// Proveedor para obtener los datos del usuario actual
final currentUserProvider = FutureProvider((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getCurrentUser();
}); 