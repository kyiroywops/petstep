import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryPhotoWidget extends StatelessWidget {
  final File file;
  final int index;
  final bool isMandatory;
  final Map<int, String> stepInstructions;
  final VoidCallback onRetake;

  const SummaryPhotoWidget({
    super.key,
    required this.file,
    required this.index,
    required this.isMandatory,
    required this.stepInstructions,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el título que se muestra arriba de la foto
    String photoLabel;
    if (isMandatory) {
      // index=0 => step=1 => "Imagen General"
      final stepNum = index + 1;
      photoLabel = stepInstructions[stepNum] ?? "Paso $stepNum";
    } else {
      // Fotos extras => "Foto adicional #n"
      photoLabel = "Foto adicional ${index + 1}";
    }

    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Texto arriba de la foto
          Text(
            photoLabel,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          // Imagen
          Image.file(
            file,
            height: 130,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          // Botón "Tomar de nuevo"
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRetake();
            },
            child: Row(
              children: [
                Icon(Icons.refresh, color: Colors.grey.shade400, size: 12),
                const SizedBox(width: 5),
                Text(
                  "Tomar de nuevo",
                  style: GoogleFonts.outfit(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}