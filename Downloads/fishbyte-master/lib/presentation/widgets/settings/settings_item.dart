import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsItem extends StatelessWidget {
  final String svgPath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsItem({
    Key? key,
    required this.svgPath,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Círculo con el SVG
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgPath,
                  width: 18,
                  height: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Título y subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Flecha lateral
            Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.grey.shade500,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
