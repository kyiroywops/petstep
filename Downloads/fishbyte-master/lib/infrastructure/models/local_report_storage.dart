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
  }
}
