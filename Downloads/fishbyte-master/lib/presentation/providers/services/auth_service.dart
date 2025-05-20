import 'package:fishbyte/presentation/providers/login/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthCheckScreen extends ConsumerStatefulWidget {
  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends ConsumerState<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Obtenemos el repositorio de autenticación desde el provider
    final authRepository = ref.read(authRepositoryProvider);
    
    // Verificamos si el usuario está autenticado
    final isAuthenticated = await authRepository.isAuthenticated();
    
    if (!isAuthenticated) {
      // Si no está autenticado, vamos a la pantalla de login
      if (mounted) {
        Future.microtask(() => context.go('/login'));
      }
      return;
    }
    
    // También verificamos que el usuario tenga una sesión activa en Supabase
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session == null || session.accessToken.isEmpty) {
      // Si no hay sesión válida, ir a login
      if (mounted) {
        Future.microtask(() => context.go('/login'));
      }
      return;
    }
    
    // Si está autenticado y la sesión es válida, vamos a la pantalla principal
    if (mounted) {
      Future.microtask(() => context.go('/home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se chequea el estado, se muestra un indicador de carga
    return const Scaffold(
      body: Center(child: CupertinoActivityIndicator()),
    );
  }
}
