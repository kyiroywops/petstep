import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:fishbyte/presentation/controllers/login_controller.dart';

class SettingsFooter extends ConsumerWidget {
  const SettingsFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar el estado del loginController para mostrar indicadores de carga
    final loginState = ref.watch(loginControllerProvider);
    
    return Column(
      children: [
        
        TextButton(
          onPressed: loginState is AsyncLoading 
            ? null // Deshabilitar si está en proceso
            : () async {
              // Mostrar un diálogo de confirmación
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Cerrar sesión',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    '¿Estás seguro que deseas cerrar sesión?',
                    style: GoogleFonts.outfit(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.outfit(),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.outfit(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              
              // Si el usuario confirmó
              if (confirm == true) {
                HapticFeedback.lightImpact();
                
                // Mostrar indicador de carga
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Cerrando sesión...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                
                try {
                  // Cerrar sesión
                  await ref.read(loginControllerProvider.notifier).logout();
                  
                  // Si todo fue exitoso, navegar a login
                  if (context.mounted) {
                    context.go('/login');
                  }
                } catch (e) {
                  // Mostrar error si falla
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cerrar sesión: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          child: loginState is AsyncLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                'Cerrar sesión',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        Image.asset(
          'assets/images/logo.webp',
          width: 90,
        ),
        const SizedBox(height: 15),
        Text(
          'Versión 2.1.1',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w200,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
