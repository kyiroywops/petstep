import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:fishbyte/presentation/widgets/upload_queue_bar.dart';
import 'package:fishbyte/presentation/providers/photos_state_provider.dart';
import 'package:fishbyte/presentation/providers/tryagain_report_provider.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';

class RegistroTerminadoOpciones extends ConsumerStatefulWidget {
  const RegistroTerminadoOpciones({Key? key}) : super(key: key);

  @override
  ConsumerState<RegistroTerminadoOpciones> createState() =>
      _RegistroTerminadoOpcionesState();
}

class _RegistroTerminadoOpcionesState extends ConsumerState<RegistroTerminadoOpciones> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }

  // Método para manejar la navegación al inicio
  void _navigateToHome() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (!mounted) return;
    
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    context.go('/registros');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Column(
          children: [
            const UploadQueueBar(),
            const SizedBox(height: 50),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      FontAwesomeIcons.solidCircleCheck,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 20),

                    // Título principal
                    Text(
                      "Caso finalizado",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "¿Qué deseas hacer a continuación?",
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botones principales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- BOTÓN: Repetir registro con los mismos datos ---
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();

                            // 1) Leemos el último reporte finalizado
                            final lastFinished =
                                ref.read(lastFinishedReportProvider);

                            if (lastFinished == null) {
                              // No hay último reporte
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "No hay un reporte previo para repetir.",
                                  ),
                                ),
                              );
                              return;
                            }

                            // 2) Generar un nuevo idGlobal y fecha/hora actual
                            final now = DateTime.now();
                            final day = now.day.toString().padLeft(2, '0');
                            final month = now.month.toString().padLeft(2, '0');
                            final year = now.year.toString();
                            final hour = now.hour.toString().padLeft(2, '0');
                            final minute = now.minute.toString().padLeft(2, '0');
                            final second = now.second.toString().padLeft(2, '0');

                            final newIdGlobal =
                                "LYTHIUM-$day-$month-$year-$hour:$minute:$second";

                            // Fecha/hora UTC
                            final nowUtc = DateTime.now().toUtc();
                            final dateNow =
                                nowUtc.toIso8601String().split('.').first + 'Z';

                            // 3) Crear el NEW draft con copyWith,
                            //    preservando center, cage, enterprise, etc.
                            final newDraft = lastFinished.copyWith(
                              idGlobal: newIdGlobal,
                              date: dateNow,
                              subido: false, // Lo volvemos "falso"
                              weight: 0.0,   // Reiniciamos el peso
                              imagenes: const [], // Sin fotos del reporte anterior
                              name: "Reporte-$newIdGlobal",
                              status: "readyToUpload",
                            );

                            // 4) Guardamos en draftReportProvider
                            ref.read(draftReportProvider.notifier).state =
                                newDraft;

                            debugPrint("NEW DRAFT => $newDraft");

                            // 5) Ir directo a la pantalla de peso
                            context.go('/weightselection');
                            // Nota: Sin revertir orientación, se mantiene horizontal.
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Repetir caso mismos parámetros",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        // --- BOTÓN: Registrar datos nuevos ---
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();

                            // Reseteamos la sesión de fotos para empezar de cero
                            ref.read(photoSessionProvider.notifier).reset();

                            // Navegar a la pantalla de selección de centro.
                            context.go('/centerselection');
                            // Se mantiene en horizontal.
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Nuevo caso",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        // --- BOTÓN: Volver al inicio ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          // Modificar el botón "Volver al inicio":
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _navigateToHome();
                          },

                          child: Text(
                            "Volver al inicio",
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
