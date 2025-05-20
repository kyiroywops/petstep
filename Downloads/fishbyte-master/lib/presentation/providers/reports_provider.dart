import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fishbyte/infrastructure/models/local_report_storage.dart';
import 'package:fishbyte/infrastructure/models/local_report.dart';

/// Proveedor que mantiene un reporte “en construcción” (draft):
final draftReportProvider = StateProvider<LocalReport?>((ref) => null);

/// Proveedor Future que busca todos los reportes en Documents/Lythium/*/estado.json 
/// y retorna una lista de LocalReport.
final allReportsProvider = FutureProvider<List<LocalReport>>((ref) async {
  final rootDir = await LocalReportStorage.getRootLythiumDir();

  if (!rootDir.existsSync()) {
    return [];
  }

  // Listar todas las subcarpetas dentro de Lythium/
  final subdirs = rootDir
      .listSync()
      .where((f) => f is Directory)
      .map((f) => f.path)
      .toList();

  final List<LocalReport> reports = [];

  for (final folderPath in subdirs) {
    // El nombre de la carpeta, p.ej. “Reporte-1234…”:
    final folderName = folderPath.split('/').last;

    // Intenta leer su estado.json
    final localReport = await LocalReportStorage.readFromLocalFile(folderName);
    if (localReport != null) {
      reports.add(localReport);
    }
  }

  return reports;
});
