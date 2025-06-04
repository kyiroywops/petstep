import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fishbyte/presentation/providers/upload_queue_provider.dart';

class UploadQueueBar extends ConsumerWidget {
  const UploadQueueBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos la cola
    final tasks = ref.watch(uploadQueueProvider);
    if (tasks.isEmpty) {
      // Si no hay nada en la cola, no mostramos nada
      return const SizedBox.shrink();
    }

    // Calculamos cuántas están "uploading" y "pending"
    final uploading = tasks.where((t) => t.status == "uploading").length;
    final pending = tasks.where((t) => t.status == "pending").length;

    // Progreso promedio sólo de las que están uploading
    double totalProgress = 0;
    int uploadCount = 0;
    for (final t in tasks) {
      if (t.status == "uploading") {
        totalProgress += t.progress; // 0..100
        uploadCount++;
      }
    }
    final averageProgress = (uploadCount == 0) ? 0 : (totalProgress / uploadCount);
    
    // Debug solo cuando hay cambios significativos de progreso
    if (uploadCount > 0 && averageProgress % 10 == 0) {
      debugPrint("🔍 UI - Progreso promedio: ${averageProgress.toStringAsFixed(1)}% (${uploadCount} tareas activas)");
    }

    // Mensaje
    final text = 
      "Subiendo $uploading caso${uploading == 1 ? '' : 's'} en progreso, "
      "$pending caso${pending == 1 ? '' : 's'} en cola... "
      "(${averageProgress.toStringAsFixed(0)}% aprox)";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration:  BoxDecoration(
        color: Colors.greenAccent.shade400,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Un "circular" que muestre el averageProgress
          SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: averageProgress / 100.0,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                Center(
                  child: Text(
                    "${averageProgress.toStringAsFixed(0)}%",
                    style: GoogleFonts.outfit(fontSize: 8, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 11),
            ),
          ),
          // Botón para limpiar terminadas:
          GestureDetector(
            onTap: () {
              ref.read(uploadQueueProvider.notifier).clearFinished();
            },
            child: const Icon(FontAwesomeIcons.circleXmark, color: Colors.white, size: 15),
          )
        ],
      ),
    );
  }
}
