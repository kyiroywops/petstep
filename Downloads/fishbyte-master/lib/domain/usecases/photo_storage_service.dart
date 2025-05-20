import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  /////////////////////////////////////////////////////////////
  // NOMBRE ARCHIVO 4 OBLIGATORIAS
  /////////////////////////////////////////////////////////////
  String _fileNameForStep(int step) {
    switch (step) {
      case 1:
        return "Completo.jpg";
      case 2:
        return "Branquias.jpg";
      case 3:
        return "Tejidosinternos.jpg";
      case 4:
        return "Organos.jpg";
      default:
        return "Additional_$step.jpg";
    }
  }

  /////////////////////////////////////////////////////////////
  // GUARDAR OBLIGATORIA
  /////////////////////////////////////////////////////////////
  Future<String> saveMandatory(XFile xfile, int step, String idGlobal) async {
    // Directorio base
    final docs = await getApplicationDocumentsDirectory();
    final sessionDir = Directory(p.join(docs.path, idGlobal));
    if (!sessionDir.existsSync()) {
      sessionDir.createSync(recursive: true);
    }

    final fname = _fileNameForStep(step);
    final path = p.join(sessionDir.path, fname);

    // Corregir orientación EXIF
    final rotatedFile = await FlutterExifRotation.rotateAndSaveImage(
      path: xfile.path,
    );

    final correctedBytes = await rotatedFile.readAsBytes();
    final file = File(path);
    await file.writeAsBytes(correctedBytes);

    return path;
  }

  /////////////////////////////////////////////////////////////
  // GUARDAR EXTRA
  /////////////////////////////////////////////////////////////
  Future<String> saveExtra(XFile xfile, int extraIndex, String idGlobal) async {
    final docs = await getApplicationDocumentsDirectory();
    final sessionDir = Directory(p.join(docs.path, idGlobal));
    if (!sessionDir.existsSync()) {
      sessionDir.createSync(recursive: true);
    }

    final fname = "fotoadicional_${extraIndex + 1}.jpg";
    final path = p.join(sessionDir.path, fname);
    final file = File(path);
    await file.writeAsBytes(await xfile.readAsBytes());

    return path;
  }
}