import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'package:fishbyte/presentation/providers/photos_state_provider.dart';

/// Widget para mostrar un atajo de registro de nuevo caso
class ShortCutRegistros extends ConsumerWidget {
  final String? username;
  final String? enterpriseName;
  final String? roleName;

  const ShortCutRegistros({
    Key? key,
    this.username,
    this.enterpriseName,
    this.roleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Para mostrar un loader en lo que cargan los datos
    if (username == null && enterpriseName == null && roleName == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registra un nuevo caso',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 300,
              child: Text(
                'Diagnostica rápidamente: captura las 4 fotos necesarias y sube '
                'el análisis del pescado en minutos.',
                style: GoogleFonts.outfit(
                  color: Colors.grey[400],
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Reseteamos la sesión de fotos para empezar de cero
                ref.read(photoSessionProvider.notifier).reset();
                context.go('/splash-orientation');
              },
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'Registrar nuevo caso',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
