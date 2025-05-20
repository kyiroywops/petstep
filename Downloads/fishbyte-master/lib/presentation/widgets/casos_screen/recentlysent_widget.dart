// recently_sent_widget.dart
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:fishbyte/presentation/providers/recentlysent_provider.dart';

class RecentlySentWidget extends ConsumerWidget {
  final String title;

  const RecentlySentWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyAsync = ref.watch(recentlySentProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: recentlyAsync.when(
          data: (items) {
            return Column(
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.go('/allrecents');
                      },
                      child: Text(
                        'Ver todos',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey.shade800),
                
                if (items.isEmpty)
                  // No hay elementos
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        SvgPicture.asset(
                          'assets/svg/help.svg',
                          color: Colors.white,
                          height: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No hay casos guardados",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Presiona el botón 'Registrar nuevo caso' y luego sube un nuevo caso.",
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      // Tomar los últimos 2 (más recientes primero)
                      final recentTwo = items.reversed.take(2).toList();

                      return Column(
                        children: [
                          for (int i = 0; i < recentTwo.length; i++) ...[
                            // Obtener la fecha 'sentAt'
                            _buildRecentItem(
                              centerName: recentTwo[i]["centerName"] ?? '',
                              cageName:   recentTwo[i]["cageName"]   ?? '',
                              timeAgo:    _computeTimeAgo(recentTwo[i]["sentAt"] as String?),
                            ),
                            if (i < recentTwo.length - 1)
                              Divider(color: Colors.grey.shade800, height: 0.8),
                          ]
                        ],
                      );
                    },
                  ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CupertinoActivityIndicator()),
          ),
          error: (err, st) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Error al cargar recientes: $err",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  /// Ejemplo de tu propia función de time-ago
  String _computeTimeAgo(String? sentAt) {
    if (sentAt == null || sentAt.isEmpty) {
      return 'Hace poco';
    }
    final date = DateTime.tryParse(sentAt);
    if (date == null) {
      return 'Hace poco';
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

  Widget _buildRecentItem({
    required String centerName,
    required String cageName,
    required String timeAgo,
  }) {
    return Row(
      children: [
        Padding(
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
              Icon(
                FontAwesomeIcons.solidCircleCheck,
                color: Colors.greenAccent.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
