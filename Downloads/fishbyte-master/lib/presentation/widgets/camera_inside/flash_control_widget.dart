import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Un widget que recibe un CameraController y permite
/// encender/apagar el flash con un botón.
class FlashToggleButton extends StatefulWidget {
  final CameraController controller;

  const FlashToggleButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<FlashToggleButton> createState() => _FlashToggleButtonState();
}

class _FlashToggleButtonState extends State<FlashToggleButton> {
  bool _flashOn = false; // Flash desactivado por defecto

  @override
  void initState() {
    super.initState();
    // Aseguramos que por defecto esté OFF
    widget.controller.setFlashMode(FlashMode.off);
  }

  Future<void> _toggleFlash() async {
    HapticFeedback.lightImpact();
    _flashOn = !_flashOn;
    setState(() {}); // Para redibujar el icono

    if (_flashOn) {
      // Encender flash
      await widget.controller.setFlashMode(FlashMode.torch);
    } else {
      // Apagar flash
      await widget.controller.setFlashMode(FlashMode.off);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggleFlash,
      icon: Icon(
        _flashOn ? Icons.flash_on : Icons.flash_off,
        color: Colors.white,
      ),
    );
  }
}
