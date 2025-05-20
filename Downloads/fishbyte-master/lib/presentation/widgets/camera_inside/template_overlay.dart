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
        final w = cts.maxWidth * 0.65;
        final h = cts.maxHeight * 0.65;
        return Stack(
          children: [
            Positioned(
              left: cts.maxWidth * 0.05,
              top: cts.maxHeight * 0.15,
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