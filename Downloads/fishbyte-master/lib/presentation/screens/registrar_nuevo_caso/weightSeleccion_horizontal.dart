import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:fishbyte/presentation/providers/kg_provider.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';

class HorizontalWeightSelection extends ConsumerStatefulWidget {
  const HorizontalWeightSelection({Key? key}) : super(key: key);

  @override
  ConsumerState<HorizontalWeightSelection> createState() => _HorizontalWeightSelectionState();
}

class _HorizontalWeightSelectionState extends ConsumerState<HorizontalWeightSelection> {
  @override
  void initState() {
    super.initState();
    // Forzamos la orientación a horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Observa el provider que controla el valor del slider (float de 0 a 5).
    final weight = ref.watch(selectedWeightProvider);
    final weightNotifier = ref.watch(selectedWeightProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
               Positioned(
                left: 0,
                top: 10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.go('/jaulaselection');
                    },
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 10),
                  // Barra simulada de "drag" (opcional)
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
              
                  Text(
                    "Ingresar peso",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Ingresa el peso del pez para completar tu caso.",
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
              
                  // Texto con el valor actual (ej: "2.4 kg")
                  Text(
                    "${weight.toStringAsFixed(1)} kg",
                    style: GoogleFonts.outfit(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 30),
              
                  // Slider de 0 a 5 kg, con saltos de 0.1
                  Slider(
                    value: weight,
                    min: 0.0,
                    max: 9.0,
                    divisions: 90,
                    label: "${weight.toStringAsFixed(1)} kg",
                    onChanged: (newValue) {
                      HapticFeedback.lightImpact();
                      // Actualiza el provider del slider con exactamente un decimal
                      weightNotifier.state = double.parse(newValue.toStringAsFixed(1));
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.black,
                  ),
              
                  const Spacer(),
              
                  // Botón para confirmar y pasar a la cámara (o lo que corresponda)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
              
                        // 1) Obtenemos el draft actual (LocalReport en memoria)
                        final draft = ref.read(draftReportProvider);
                        if (draft == null) {
                          // Si es null, no hay reporte en progreso
                          Navigator.of(context).pop();
                          return;
                        }
              
                        // 2) Usamos copyWith para actualizar el peso
                        final updatedDraft = draft.copyWith(weight: weight);
                        ref.read(draftReportProvider.notifier).state = updatedDraft;
              
                        // (Opcional) Imprimimos en consola para debug
                        debugPrint("DRAFT REPORT (Weight selected): $updatedDraft");
              
              
                        // 4) Navegar a la cámara en modo fullscreen (ruta '/fullscreenCamera'),
                        //    o la siguiente pantalla de tu flujo
                        context.push('/fullscreenCamera');
                      },
                      child: Text(
                        "Siguiente",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
