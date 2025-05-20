import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fishbyte/presentation/providers/connectivity_provider.dart';
import 'package:fishbyte/presentation/providers/pendingcount_provider.dart';
import 'package:fishbyte/presentation/providers/senttotal_counter_provider.dart';
class InformacionEstadosWidget extends ConsumerWidget {
  final String? username;
  final String? enterpriseName;
  final String? roleName;

  const InformacionEstadosWidget({
    Key? key,
    this.username,
    this.enterpriseName,
    this.roleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos otros providers que ya tenías
    final sentAsync = ref.watch(sentCounterProvider);
    final pendingCount = ref.watch(pendingReportsCountProvider);

    // Observamos el provider que nos da el TIPO de conexión
    final connectionTypeAsync = ref.watch(connectionTypeProvider);

    // Loader si todavía no tenemos la info de usuario
    if (username == null && enterpriseName == null && roleName == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de estados',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Divider(color: Colors.grey[800]),

            // 1) Estado de conexión
            // En lugar de texto fijo, usamos connectionTypeProvider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conexión a internet',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // Aquí mostramos el estado según `connectionTypeAsync`
                connectionTypeAsync.when(
                  loading: () => Text(
                    'Cargando...',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  error: (error, stack) => Text(
                    'Error',
                    style: GoogleFonts.outfit(
                      color: Colors.redAccent.shade200,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  data: (connectionType) {
                    // Si la descripción es 'Sin conexión a Internet', usamos color rojo, de lo contrario verde
                    final isNoConnection = connectionType == "Sin conexión a Internet";
                    final textColor = isNoConnection
                        ? Colors.redAccent.shade400
                        : Colors.greenAccent.shade200;

                    return Text(
                      connectionType,
                      style: GoogleFonts.outfit(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 2) Registros subidos
            sentAsync.when(
              loading: () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registros subidos',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const CupertinoActivityIndicator(),
                ],
              ),
              error: (err, st) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registros subidos',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'ERR',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              data: (count) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registros subidos',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$count',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 3) Registros pendientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registros pendientes',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$pendingCount',
                  style: GoogleFonts.outfit(
                    color: Colors.redAccent.shade200,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
