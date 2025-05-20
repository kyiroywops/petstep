import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/////////////////////////////////////////////////////////////
// VISTA PREVIA (según plataforma)
/////////////////////////////////////////////////////////////
class BuildCameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const BuildCameraPreviewWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = controller.value.aspectRatio;

    if (Platform.isAndroid) {
      // Ajustes para Android => rotar manual + invertir ratio
      return RotatedBox(
        quarterTurns: 1,
        child: AspectRatio(
          aspectRatio: 1 / ratio,
          child: CameraPreview(controller),
        ),
      );
    } else if (Platform.isIOS) {
      // Ajustes para iOS => se suele mostrar bien con aspectRatio normal
      return AspectRatio(
        aspectRatio: ratio,
        child: CameraPreview(controller),
      );
    } else {
      // Caso por defecto (otros SO)
      return CameraPreview(controller);
    }
  }
}