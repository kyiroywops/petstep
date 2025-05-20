import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';   

import 'package:fishbyte/presentation/providers/upload_queue_provider.dart';
import 'package:fishbyte/infrastructure/models/local_report.dart';

Widget buildTrailingWidget(WidgetRef ref, LocalReport rep) {
  final uploadQueue = ref.watch(uploadQueueProvider);
  // Buscamos si hay un UploadTask para este rep
  final task = uploadQueue.firstWhereOrNull(
    (t) => t.report.idGlobal == rep.idGlobal,
  );

  // Si NO está en cola => botón "Enviar"
  if (task == null) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Encolamos en la cola => se procesará
        ref.read(uploadQueueProvider.notifier).enqueue(rep);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Enviar",
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Si SÍ está en cola => Verificamos su 'status'
  switch (task.status) {
    case "uploading":
      return const CupertinoActivityIndicator(
        radius: 10,
        color: Colors.white,
      );

    case "done":
      return const Icon(
        CupertinoIcons.check_mark_circled_solid,
        color: Colors.greenAccent,
        size: 20,
      );

    case "error":
      return GestureDetector(
        onTap: () {
          ref.read(uploadQueueProvider.notifier).enqueue(rep);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Error",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

    case "pending":
    default:
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "En cola...",
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
  }
}
