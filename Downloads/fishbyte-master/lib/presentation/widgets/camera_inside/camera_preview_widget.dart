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
    if (Platform.isAndroid) {
      return _buildAndroidPreview(context);
    } else if (Platform.isIOS) {
      return _buildIOSPreview();
    } else {
      return CameraPreview(controller);
    }
  }

  Widget _buildAndroidPreview(BuildContext context) {
    // Enfoque simple: Solo ajustar el aspect ratio para Android
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.width ?? 0,
          height: controller.value.previewSize?.height ?? 0,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildIOSPreview() {
    final ratio = controller.value.aspectRatio;
    return AspectRatio(
      aspectRatio: ratio,
      child: CameraPreview(controller),
    );
  }
}