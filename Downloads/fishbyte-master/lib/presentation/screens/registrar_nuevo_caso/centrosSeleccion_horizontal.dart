import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import 'package:fishbyte/presentation/providers/data_centers_and_cages_provider.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';
import 'package:fishbyte/presentation/providers/user_id_provider.dart';
import 'package:fishbyte/infrastructure/models/local_report.dart';

class HorizontalCenterSelection extends ConsumerStatefulWidget {
  const HorizontalCenterSelection({Key? key}) : super(key: key);

  @override
  HorizontalCenterSelectionState createState() =>
      HorizontalCenterSelectionState();
}

class HorizontalCenterSelectionState
    extends ConsumerState<HorizontalCenterSelection> {
  @override
  void initState() {
    super.initState();
    // Forzamos la orientación a horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }

  void goLeft(int currentIndex, int maxIndex,
      StateController<int> centerIndexNotifier) {
    if (currentIndex > 0) {
      centerIndexNotifier.state = currentIndex - 1;
    }
  }

  void goRight(int currentIndex, int maxIndex,
      StateController<int> centerIndexNotifier) {
    if (currentIndex < maxIndex) {
      centerIndexNotifier.state = currentIndex + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1) Observa userIdProvider
    final userIdAsync = ref.watch(userIdProvider);
    // 2) Observa la lista de centros
    final centersAsync = ref.watch(centersFutureProvider);

    // Renderizamos combinando ambos .when
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: userIdAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (err, st) => Center(
            child: Text(
              "Error al cargar userId: $err",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (userId) {
            // Una vez que tenemos el userId, ahora anidamos la lógica de centers:
            return centersAsync.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, st) => Center(
                child: Text(
                  "Error al cargar centros: $error",
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              data: (centers) {
                if (centers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay centros disponibles",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final centerIndex = ref.watch(selectedCenterIndexProvider);
                final centerIndexNotifier =
                    ref.watch(selectedCenterIndexProvider.notifier);

                final lastIndex = centers.length - 1;
                final currentCenter = centers[centerIndex];

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
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              // Usar la pantalla de splash para manejar la transición de vuelta a vertical
                              context.go('/splash-back-to-vertical?target=/registros');
                            },
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          // Barra "drag" (opcional)
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
                            "Selecciona tu centro",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Selecciona el centro correspondiente para tu nuevo caso.",
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),

                          // Flechas Izquierda / Derecha + Nombre del centro
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
                                    goLeft(centerIndex, lastIndex,
                                        centerIndexNotifier);
                                  },
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    currentCenter.name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontSize: 25,
                                    ),
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
                                    goRight(centerIndex, lastIndex,
                                        centerIndexNotifier);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Botón Siguiente
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
                              onPressed: () async {
                                HapticFeedback.lightImpact();

                                // 1) Generar el idGlobal con el formato LYTHIUM-dd-mm-yyyy-HH:MM:SS
                                final now = DateTime.now();
                                final day = now.day.toString().padLeft(2, '0');
                                final month =
                                    now.month.toString().padLeft(2, '0');
                                final year = now.year.toString();
                                final hour =
                                    now.hour.toString().padLeft(2, '0');
                                final minute =
                                    now.minute.toString().padLeft(2, '0');
                                final second =
                                    now.second.toString().padLeft(2, '0');
                                final customIdGlobal =
                                    "LYTHIUM-$day-$month-$year-$hour:$minute:$second";

                                // 2) Fecha/hora en UTC con "Z"
                                final nowUtc = DateTime.now().toUtc();
                                final dateNow =
                                    nowUtc.toIso8601String().split('.').first +
                                        'Z';

                                // 3) Obtener la empresa seleccionada desde SharedPreferences
                                final prefs = await SharedPreferences.getInstance();
                                final enterpriseData = prefs.getString('enterpriseData');
                                String selectedEnterpriseId = '1'; // Valor por defecto
                                
                                if (enterpriseData != null) {
                                  final Map<String, dynamic> enterprise = json.decode(enterpriseData);
                                  selectedEnterpriseId = enterprise['id'] ?? '1';
                                }
                                
                                // 4) Crear un LocalReport inicial con la empresa seleccionada
                                final newReport = LocalReport(
                                  idGlobal: customIdGlobal,
                                  date: dateNow,
                                  weight: 0.0,
                                  subido: false,
                                  name: "Reporte-$customIdGlobal",
                                  status: "readyToUpload",
                                  enterprise: selectedEnterpriseId, // Usar la empresa seleccionada en el login
                                  user: userId.toString(),
                                  especie: "Pendiente",
                                  center: CenterData(
                                    id: currentCenter.id,
                                    name: currentCenter.name,
                                    ACS: currentCenter.ACS,
                                    SIEP: currentCenter.SIEP,
                                    water: currentCenter.water,
                                    category: currentCenter.category,
                                    species: currentCenter.species,
                                  ),
                                  cage: const CageData(
                                    id: '0',
                                    name: "",
                                  ),
                                  imagenes: const [],
                                );

                                // 4) Guardamos en draftReportProvider
                                ref.read(draftReportProvider.notifier).state =
                                    newReport;

                                // 5) Navegamos a la pantalla de selección de jaula
                                context.go('/jaulaselection');
                              },
                              child: Text(
                                "Siguiente",
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 52, 38, 38),
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
            );
          },
        ),
      ),
    );
  }
}
