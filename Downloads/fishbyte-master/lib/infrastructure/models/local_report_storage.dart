// lib/infrastructure/usecases/local_report_storage.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fishbyte/infrastructure/models/local_report.dart';

class LocalReportStorage {

  /// Devuelve el directorio base (Documents/Lythium)
  static Future<Directory> getRootLythiumDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    return Directory("${docDir.path}/Lythium");
  }

  /// Guarda un [report] como JSON en: Documents/Lythium/[folderName]/estado.json
  /// [folderName] podría ser algo como `report.name`, `report.idGlobal` o lo que prefieras.
  static Future<void> saveToLocalFile(LocalReport report, String folderName) async {
    final root = await getRootLythiumDir();
    final folderPath = "${root.path}/$folderName";
    final folder = Directory(folderPath);

    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    final filePath = "$folderPath/estado.json";
    final file = File(filePath);

    final jsonStr = json.encode(report.toJson());
    await file.writeAsString(jsonStr, flush: true);

    debugPrint("Reporte guardado => $filePath");
  }

  /// Lee el JSON en Documents/Lythium/[folderName]/estado.json
  static Future<LocalReport?> readFromLocalFile(String folderName) async {
    final root = await getRootLythiumDir();
    final filePath = "${root.path}/$folderName/estado.json";
    final file = File(filePath);

    if (!await file.exists()) {
      debugPrint("No existe => $filePath");
      return null;
    }

    final content = await file.readAsString();
    final map = json.decode(content) as Map<String, dynamic>;
    return LocalReport.fromJson(map);
  }

  /// Borra la carpeta entera con su JSON e imágenes
  static Future<void> deleteLocalReport(String folderName) async {
    final root = await getRootLythiumDir();
    final folderPath = "${root.path}/$folderName";
    final dir = Directory(folderPath);

    if (dir.existsSync()) {
      await dir.delete(recursive: true);
      debugPrint("Reporte borrado => $folderPath");
    }
    
    // NUEVO: También borrar las imágenes originales y las copias permanentes
    await _cleanupRelatedImages(folderName);
  }
  
  /// Limpia las imágenes relacionadas con un reporte (fotos originales y copias)
  static Future<void> _cleanupRelatedImages(String reportName) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      
      // Primero intentamos leer el reporte para obtener su idGlobal
      String? idGlobal;
      try {
        final report = await readFromLocalFile(reportName);
        idGlobal = report?.idGlobal;
        debugPrint("🔍 idGlobal obtenido del reporte: $idGlobal");
      } catch (e) {
        debugPrint("⚠️ No se pudo leer el reporte $reportName para obtener idGlobal: $e");
        // Si no podemos leer el reporte, usamos el reportName como fallback
        idGlobal = reportName;
      }
      
      if (idGlobal == null || idGlobal.isEmpty) {
        debugPrint("⚠️ No se pudo determinar idGlobal para limpiar imágenes");
        return;
      }
      
      // 1. Borrar directorio de fotos originales (Documents/idGlobal/)
      final originalPhotosDir = Directory("${docDir.path}/$idGlobal");
      if (originalPhotosDir.existsSync()) {
        await originalPhotosDir.delete(recursive: true);
        debugPrint("🗑️ Borrado directorio de fotos originales: ${originalPhotosDir.path}");
      } else {
        debugPrint("ℹ️ Directorio de fotos originales no existe: ${originalPhotosDir.path}");
      }
      
      // 2. Borrar copias permanentes (Documents/report_images/idGlobal/)
      final reportImagesDir = Directory("${docDir.path}/report_images/$idGlobal");
      if (reportImagesDir.existsSync()) {
        await reportImagesDir.delete(recursive: true);
        debugPrint("🗑️ Borrado directorio de copias permanentes: ${reportImagesDir.path}");
      } else {
        debugPrint("ℹ️ Directorio de copias permanentes no existe: ${reportImagesDir.path}");
      }
      
      // 3. OPCIONAL: Limpiar directorio report_images si está vacío
      final reportImagesBaseDir = Directory("${docDir.path}/report_images");
      if (reportImagesBaseDir.existsSync()) {
        try {
          final contents = reportImagesBaseDir.listSync();
          if (contents.isEmpty) {
            await reportImagesBaseDir.delete();
            debugPrint("🧹 Borrado directorio base report_images (estaba vacío)");
          }
        } catch (e) {
          debugPrint("ℹ️ No se pudo verificar/borrar directorio base report_images: $e");
        }
      }
      
      debugPrint("🧹 Limpieza completa de imágenes para reporte: $reportName (idGlobal: $idGlobal)");
    } catch (e) {
      debugPrint("❌ Error durante limpieza de imágenes para $reportName: $e");
      // No lanzamos la excepción para no interrumpir el borrado del reporte principal
    }
  }
}
