import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fishbyte/domain/usecases/displaycleandate_usecases.dart';
import 'package:fishbyte/infrastructure/models/local_report.dart';
import 'package:fishbyte/infrastructure/models/local_report_storage.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';
import 'package:fishbyte/presentation/providers/upload_queue_provider.dart';
import 'package:fishbyte/presentation/widgets/casos_screen/trailing_enviar.dart';

/// Widget que muestra la sección "Registros no enviados"
/// Se encarga de listar los reportes con status 'readyToUpload'
/// y permitir su envío o eliminación.
class NotSentReportsWidget extends ConsumerWidget {
  const NotSentReportsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos la lista de reportes
    final reportsAsync = ref.watch(allReportsProvider);
    // Observamos la cola de uploads
    final uploadQueue = ref.watch(uploadQueueProvider);

    // Verificamos si hay alguna subida en curso
    final isUploading = uploadQueue.any((task) => task.status == "uploading");

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: reportsAsync.when(
          data: (allReports) {
            // Filtramos los reportes pendientes de subir
            final notSent = allReports
    .where((r) => r.status == 'readyToUpload' || r.status == 'error')
    .toList();


            return Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Casos no enviados',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // Botón "Subir todos"
                    GestureDetector(
                      onTap: (notSent.isEmpty || isUploading)
                          ? null
                          : () {
                              HapticFeedback.lightImpact();

                              // Encolamos todos los reportes pendientes
                              ref
                                  .read(uploadQueueProvider.notifier)
                                  .enqueueMultiple(notSent);

                              // Snack de confirmación
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Se encolaron ${notSent.length} reportes pendientes',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700
                                    ),
                                  ),
                                  backgroundColor: Colors.green.shade400,
                                ),
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: notSent.isEmpty
                              ? Colors.grey
                              : (isUploading
                                  ? Colors.orange
                                  : Colors.redAccent.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Subir todos',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            SvgPicture.asset(
                              'assets/svg/uploadbox.svg',
                              color: Colors.white,
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey.shade800),

                // Si está vacío, mostramos un estado "no hay pendientes"
                if (notSent.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notSent.length,
                    itemBuilder: (context, index) {
                      final rep = notSent[index];
                      final firstImage = rep.imagenes.isNotEmpty
                          ? rep.imagenes.first
                          : null;

                      // Leading: foto o fallback
                      Widget leadingWidget;
                      if (firstImage != null &&
                          File(firstImage.img).existsSync()) {
                        leadingWidget = Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: FileImage(File(firstImage.img)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else {
                        leadingWidget = Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.white,
                          ),
                        );
                      }

                      return ListTile(
                        leading: leadingWidget,
                        title: Text(
                          "${rep.center.name} • Jaula ${rep.cage.name}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/calendar.svg',
                                  color: Colors.white,
                                  height: 13,
                                ),
                                const SizedBox(width: 5),
                                DisplayCleanDate(isoDate: rep.date),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/kg.svg',
                                  color: Colors.white,
                                  height: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${rep.weight.toStringAsFixed(2)} KG",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // trailing se compone en otro widget (trailing_enviar.dart),
                        // o donde lo tengas definido
                        trailing: buildTrailingWidget(ref, rep),
                        onTap: () {
                          // Muestra las imágenes del reporte
                          _showImagesForReport(context, ref, rep);
                        },
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.shade800,
                      height: 0.8,
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, st) => Center(
            child: Text(
              "Error al cargar reportes: $error",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  /// Mostramos un UI de "No hay casos pendientes"
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          SvgPicture.asset(
            'assets/svg/help.svg',
            color: Colors.white,
            height: 50,
          ),
          const SizedBox(height: 10),
          Text(
            "No hay casos pendientes",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Presiona el botón 'Registrar nuevo caso' para añadir un nuevo caso.",
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Muestra un bottom sheet con las imágenes de un reporte
  void _showImagesForReport(
      BuildContext context, WidgetRef ref, LocalReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final images = report.imagenes;
        if (images.isEmpty) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text("No hay imágenes para este reporte")),
          );
        }

        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Barra de "drag"
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Imágenes del Reporte",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Borrar el reporte local
                      await LocalReportStorage.deleteLocalReport(report.name);

                      // Limpiar el reporte de la cola de subida si existe
                      final queueNotifier = ref.read(uploadQueueProvider.notifier);
                      if (queueNotifier.isReportInQueue(report)) {
                        queueNotifier.removeReportByName(report.name);
                      }

                      Navigator.of(context).pop();

                      // Snack
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Se eliminó correctamente el reporte.",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );

                      // Forzar refresh
                      ref.invalidate(allReportsProvider);
                    },
                    child: Text(
                      "Eliminar",
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: Colors.redAccent.shade400,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imgItem = images[index];
                    final file = File(imgItem.img);
                    return Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              imgItem.name,
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: file.existsSync()
                                ? Image.file(
                                    file,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.grey,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image),
                                  ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
