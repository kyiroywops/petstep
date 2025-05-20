import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Por si usas HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:fishbyte/presentation/providers/recentlysent_provider.dart';
/// Pantalla que muestra hasta 20 registros enviados recientemente,
/// con un fondo negro y estilo similar al "container gris + texto blanco".
class AllRecentsScreen extends ConsumerWidget {
  const AllRecentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos la lista "recentlySentReports" desde SharedPreferences
    final recentlyAsync = ref.watch(recentlySentProvider);

    return Scaffold(
      body: recentlyAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (err, st) => Center(
          child: Text(
            "Error al cargar: $err",
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (items) {
          // Si está vacío => un mensaje
          if (items.isEmpty) {
            return _buildEmpty(context);
          }

          // Tomamos los últimos 20 en orden de "más reciente a más antiguo"
          final last20 = items.reversed.take(20).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go('/registros');
                        },
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Casos enviados",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Últimos 20 registros",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ), 
                            )
                          ],
                        ),
                        Divider(color: Colors.grey.shade800),

                        // Construimos cada item
                        for (int i = 0; i < last20.length; i++) ...[
                          _buildRecentItem(last20[i]),
                          // Divider si no es el último
                          if (i < last20.length - 1)
                          SizedBox(height: 5),
                            Divider(color: Colors.grey.shade800, height: 0.8),
                              SizedBox(height: 5),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Un pequeño método para mostrar "No hay registros" con estilo
  Widget _buildEmpty(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.go('/registros');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            SvgPicture.asset(
              'assets/svg/help.svg',
              color: Colors.white,
              height: 50,
            ),
            const SizedBox(height: 10),
            Text(
              "No hay registros guardados",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Presiona el botón 'Registrar nuevo caso' y sube un nuevo registro.",
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Construye un item de la lista de recientes.
  /// Cada item es un `Map<String, dynamic>` con al menos
  /// { centerName, cageName, sentAt }.
  Widget _buildRecentItem(Map<String, dynamic> item) {
    final centerName = item["centerName"] ?? '';
    final cageName   = item["cageName"]   ?? '';
    final sentAtStr  = item["sentAt"]     as String?; 
    // Obtenemos un "timeAgo" basado en la fecha.
    final timeAgo    = _computeTimeAgo(sentAtStr);

    return Row(
      children: [
        // Nombre del centro + Jaula en 2 líneas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  centerName,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cageName,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Hora + check verde
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeAgo,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Icon(
              FontAwesomeIcons.solidCircleCheck,
              color: Colors.greenAccent,
              size: 16,
            ),
          ],
        ),
      ],
    );
  }

  /// Función interna para formatear "hace X tiempo" en base a un String ISO8601.
  /// Ej: "2025-01-01T12:34:56.789Z" => "Hace 3 días" o "Hace 2 horas".
  String _computeTimeAgo(String? sentAt) {
    if (sentAt == null || sentAt.isEmpty) {
      return 'Hace poco'; // fallback
    }
    final date = DateTime.tryParse(sentAt);
    if (date == null) {
      return 'Hace poco'; // fallback si no parsea bien
    }
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) {
      return 'Hace ${diff.inSeconds} s';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} h';
    } else {
      return 'Hace ${diff.inDays} d';
    }
  }
}
