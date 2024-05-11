import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Asegúrate de que el estado de la conexión es activo antes de proceder
        if (snapshot.connectionState == ConnectionState.active) {
          // Si hay datos (usuario logueado), entonces navega a HomeScreen
          if (snapshot.hasData) {
            Future.microtask(() => context.go('/basescreen'));
          } 
          // Si no hay datos (usuario no logueado), navega a LoginScreen
          else {
            Future.microtask(() => context.go('/login'));
          }
        }
        // Mientras espera, muestra un indicador de carga
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

