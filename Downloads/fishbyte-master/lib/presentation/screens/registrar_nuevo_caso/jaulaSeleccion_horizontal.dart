import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fishbyte/infrastructure/models/local_report.dart';
import 'package:fishbyte/presentation/providers/data_centers_and_cages_provider.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';

class HorizontalCageSelector extends ConsumerStatefulWidget {
  const HorizontalCageSelector({Key? key}) : super(key: key);

  @override
  ConsumerState<HorizontalCageSelector> createState() => _HorizontalCageSelectorState();
}

class _HorizontalCageSelectorState extends ConsumerState<HorizontalCageSelector> {
  @override
  void initState() {
    super.initState();
    // Forzamos la orientación a horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      // DeviceOrientation.landscapeLeft, 
    ]);
  }


  void goLeft(int currentIndex, int maxIndex, StateController<int> cageIndexNotifier) {
    if (currentIndex > 0) {
      cageIndexNotifier.state = currentIndex - 1;
    }
  }

  void goRight(int currentIndex, int maxIndex, StateController<int> cageIndexNotifier) {
    if (currentIndex < maxIndex) {
      cageIndexNotifier.state = currentIndex + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa la lista de centros y el índice
    final centersAsync = ref.watch(centersFutureProvider);
    final centerIndex = ref.watch(selectedCenterIndexProvider);

    // Observa la jaula seleccionada
    final cageIndex = ref.watch(selectedCageIndexProvider);
    final cageIndexNotifier = ref.watch(selectedCageIndexProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: centersAsync.when(
          data: (centers) {
            if (centers.isEmpty) {
              return const Center(
                child: Text(
                  "No hay centros disponibles",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Centro actual y jaulas
            final currentCenter = centers[centerIndex];
            final cages = currentCenter.cages;

            if (cages.isEmpty) {
              return const Center(
                child: Text(
                  "Este centro no tiene jaulas",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final lastIndex = cages.length - 1;
            final currentCage = cages[cageIndex];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.arrowLeft,
                          color: Colors.black,
                          size: 13,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go('/centerselection');
                        },
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      // Barra simulada de “drag” (opcional)
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
                        "Selecciona Jaula",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Selecciona la jaula correspondiente para completar tu caso.",
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                  
                      // Flechas Izquierda / Derecha + Nombre de la Jaula
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.chevronLeft,
                                color: Colors.black,
                                size: 13,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                goLeft(cageIndex, lastIndex, cageIndexNotifier);
                              },
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                currentCage.name,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.chevronRight,
                                color: Colors.black,
                                size: 13,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                goRight(cageIndex, lastIndex, cageIndexNotifier);
                              },
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                  
                      // Botón “Siguiente”
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            // 1) Tomamos el draft actual
                            final draft = ref.read(draftReportProvider);
                            if (draft == null) {
                              // No se seleccionó centro, o algo salió mal
                              Navigator.of(context).pop();
                              return;
                            }
                  
                            // 2) Actualizamos el draft con la jaula
                            final updatedDraft = draft.copyWith(
                              cage: CageData(
                                id: currentCage.id.toString(),
                                name: currentCage.name,
                              ),
                            );
                            ref.read(draftReportProvider.notifier).state = updatedDraft;
                  
                            // Log opcional
                            debugPrint("DRAFT REPORT (Cage selected): ${ref.read(draftReportProvider)}");
                  
                            context.go('/weightselection');
                          
                  
                          },
                          child: Text(
                            "Siguiente",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stack) => Center(
            child: Text(
              "Error al cargar centros: $error",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }
}
