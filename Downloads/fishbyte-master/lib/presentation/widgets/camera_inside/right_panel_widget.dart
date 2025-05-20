import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fishbyte/presentation/screens/camera_por_dentro/photo_session_provider.dart';
/////////////////////////////////////////////////////////////
// PANEL LATERAL
/////////////////////////////////////////////////////////////
class RightPanelWidget extends ConsumerWidget {
  final int displayStep;
  final bool isRetaking;
  final bool retakeIsMandatory;
  final int? retakeIndex;
  final bool isCapturing;
  final Map<int, String> stepInstructions;
  final Map<int, String> stepExamples;
  final VoidCallback onTakePicture;

  const RightPanelWidget({
    super.key,
    required this.displayStep,
    required this.isRetaking,
    required this.retakeIsMandatory,
    required this.retakeIndex,
    required this.isCapturing,
    required this.stepInstructions,
    required this.stepExamples,
    required this.onTakePicture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(photoSessionProvider);
    final isMandatory = displayStep >= 1 && displayStep <= 4;

    // Armamos el título del panel
    String panelTitle;
    String instructions;
    String? example;

    // Si esMandatory => "1/4", "2/4", etc.
    if (isMandatory) {
      panelTitle = "$displayStep / 4";
      instructions = stepInstructions[displayStep] ?? "Paso $displayStep";
      example = stepExamples[displayStep];
    } else {
      // Foto adicional. Revisamos si estamos en retake
      if (isRetaking && !retakeIsMandatory && retakeIndex != null) {
        // Re-tomando una foto extra
        panelTitle = "Foto adicional ${retakeIndex! + 1}";
        instructions = "Re-tomar foto adicional ${retakeIndex! + 1}";
        example = null; // Generalmente no hay plantilla para extras
      } else {
        // Caso normal: foto adicional nueva
        final nextNumber = s.extras.length + 1;
        panelTitle = "Foto adicional $nextNumber";
        instructions = "Foto adicional";
        example = null;
      }
    }

    // Construimos la UI
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Título principal (por ejemplo "2/4" o "Foto adicional 3")
          Text(
            panelTitle,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Botón disparo
          GestureDetector(
            onTap: isCapturing ? null : onTakePicture,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Instrucciones + ejemplo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Text(
                  instructions,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (example != null)
                  Image.asset(
                    example,
                    fit: BoxFit.contain,
                    height: 80,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}