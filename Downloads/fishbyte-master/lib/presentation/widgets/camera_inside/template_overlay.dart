import 'dart:io';
import 'package:flutter/material.dart';

class BuildTemplateOverlay extends StatelessWidget {
  final int step;

  const BuildTemplateOverlay({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final plantillas = [
      "assets/images/plantilla1.webp",
      "assets/images/plantilla2.webp",
      "assets/images/plantilla3.webp",
      "assets/images/plantilla4.webp",
    ];
    final idx = (step - 1).clamp(0, 3);
    final asset = plantillas[idx];

    return LayoutBuilder(
      builder: (ctx, cts) {
        // Configuración específica por plataforma
        double w, h, leftOffset, topOffset;
        
        if (Platform.isIOS) {
          // iPhone: más grande y un poco más a la izquierda
          w = cts.maxWidth * 0.80;
          h = cts.maxHeight * 0.80;
          leftOffset = (cts.maxWidth - w) / 2 - cts.maxWidth * 0.07; // Mover 10% a la izquierda
          topOffset = (cts.maxHeight - h) / 2;
        } else {
          // Android: más grande y centrado
          w = cts.maxWidth * 0.85;
          h = cts.maxHeight * 0.85;
          leftOffset = (cts.maxWidth - w) / 2; // Centrado
          topOffset = (cts.maxHeight - h) / 2;
        }
        
        return Stack(
          children: [
            Positioned(
              left: leftOffset,
              top: topOffset,
              child: Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(asset),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}