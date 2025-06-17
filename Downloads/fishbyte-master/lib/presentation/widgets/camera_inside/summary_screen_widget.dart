import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:fishbyte/infrastructure/models/local_report.dart';
import 'package:fishbyte/infrastructure/models/local_report_storage.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';
import 'package:fishbyte/presentation/providers/tryagain_report_provider.dart';
import 'package:fishbyte/presentation/providers/upload_queue_provider.dart';
import 'package:fishbyte/presentation/screens/camera_por_dentro/photo_session_provider.dart';
import 'package:fishbyte/presentation/widgets/camera_inside/summary_photo_widget.dart';
/////////////////////////////////////////////////////////////
// PANTALLA RESUMEN
/////////////////////////////////////////////////////////////
class SummaryScreenWidget extends ConsumerWidget {
  final List<File> mandatory;
  final List<File> extras;
  final Map<int, String> stepInstructions;
  final Function(bool) onShowSummaryChanged;
  final Function(bool, bool, int) onRetakePhoto;

  const SummaryScreenWidget({
    super.key,
    required this.mandatory,
    required this.extras,
    required this.stepInstructions,
    required this.onShowSummaryChanged,
    required this.onRetakePhoto,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Resumen de fotos",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Galería horizontal
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fotos obligatorias
                    for (int i = 0; i < mandatory.length; i++)
                      SummaryPhotoWidget(
                        file: mandatory[i],
                        index: i,
                        isMandatory: true,
                        stepInstructions: stepInstructions,
                        onRetake: () {
                          onRetakePhoto(true, true, i);
                        },
                      ),
                    // Fotos extras
                    for (int j = 0; j < extras.length; j++)
                      SummaryPhotoWidget(
                        file: extras[j],
                        index: j,
                        isMandatory: false,
                        stepInstructions: stepInstructions,
                        onRetake: () {
                          onRetakePhoto(true, false, j);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Agregar foto adicional
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onShowSummaryChanged(false);
                    ref.read(photoSessionProvider.notifier).switchToExtraMode();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Agregar foto adicional",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Terminar caso
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    // 1) Draft
                    final draft = ref.read(draftReportProvider);
                    if (draft == null) {
                      Navigator.pop(context);
                      return;
                    }
                    
                    // Obtener el directorio de documentos para guardar copias permanentes
                    final appDocsDir = await getApplicationDocumentsDirectory();
                    final reportImagesDir = Directory(p.join(
                      appDocsDir.path, 
                      'report_images', 
                      draft.idGlobal
                    ));
                    
                    // Crear directorio si no existe
                    if (!reportImagesDir.existsSync()) {
                      reportImagesDir.createSync(recursive: true);
                    }
                    
                    // 2) Armar lista final verificando cada imagen
                    final newImages = <ImageItem>[];
                    
                    // Función para asegurar que la imagen existe y está en ubicación permanente
                    Future<String> ensureImageExists(File imageFile, String imageName) async {
                      if (!imageFile.existsSync()) {
                        debugPrint("⚠️ Advertencia: Imagen no encontrada en: ${imageFile.path}");
                        throw Exception("Imagen no encontrada: ${imageFile.path}");
                      }
                      
                      // Crear un nombre de archivo seguro
                      final safeFileName = "${DateTime.now().millisecondsSinceEpoch}_$imageName.jpg";
                      final permanentPath = p.join(reportImagesDir.path, safeFileName);
                      
                      // Copiar el archivo a la ubicación permanente
                      final permanentFile = await imageFile.copy(permanentPath);
                      debugPrint("✓ Imagen copiada a ubicación permanente: $permanentPath");
                      
                      return permanentFile.path;
                    }
                    
                    try {
                      // Mapeo de nombres descriptivos para las imágenes obligatorias
                      final mandatoryNames = {
                        0: "completo",
                        1: "branquias", 
                        2: "organos_visibles",
                        3: "organos_internos",
                      };
                      
                      // Procesar imágenes obligatorias
                      for (int i = 0; i < mandatory.length; i++) {
                        final descriptiveName = mandatoryNames[i] ?? "mandatory_${i+1}";
                        final imagePath = await ensureImageExists(mandatory[i], descriptiveName);
                        
                        newImages.add(
                          ImageItem(
                            id: i + 1,
                            name: descriptiveName,
                            img: imagePath,
                          ),
                        );
                      }
                      
                      // Procesar imágenes extras
                      final offset = mandatory.length + 1;
                      for (int j = 0; j < extras.length; j++) {
                        final additionalName = "adicional_${j + 1}";
                        final imagePath = await ensureImageExists(extras[j], additionalName);
                        
                        newImages.add(
                          ImageItem(
                            id: offset + j,
                            name: additionalName,
                            img: imagePath,
                          ),
                        );
                      }
                      
                      // 3) copyWith
                      final updated = draft.copyWith(imagenes: newImages);
                      ref.read(draftReportProvider.notifier).state = updated;
                      
                      // 4) Guardar
                      await LocalReportStorage.saveToLocalFile(
                        updated,
                        updated.name,
                      );
                      debugPrint("LocalReport + fotos guardados => ${updated.name}");

                      // 5) Encolar para subir (opcional)
                      ref.read(uploadQueueProvider.notifier).enqueue(updated);

                      // Guardar en lastFinishedReportProvider
                      final finishedReport = ref.read(draftReportProvider);
                      if (finishedReport != null) {
                        ref.read(lastFinishedReportProvider.notifier).state =
                            finishedReport;
                      }

                      // Reset
                      ref.read(photoSessionProvider.notifier).reset();
                      ref.invalidate(allReportsProvider);

                      context.go('/registroterminadoopciones');
                    } catch (e) {
                      // Mostrar error si no se pueden guardar las imágenes
                      debugPrint("❌ Error guardando imágenes: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error al guardar imágenes: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Terminar caso",
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}