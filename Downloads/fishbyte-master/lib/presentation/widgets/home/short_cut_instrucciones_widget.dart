import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Muestra un “banner” de instrucciones y lleva al onboarding
class ShortCutInstruccionesWidget extends StatelessWidget {
  final String? username;
  final String? enterpriseName;
  final String? roleName;

  const ShortCutInstruccionesWidget({
    Key? key,
    this.username,
    this.enterpriseName,
    this.roleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (username == null && enterpriseName == null && roleName == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/onboardingtutorial');
      },
      child: Container(
        width: double.infinity,
        height: 135,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: const DecorationImage(
            image: AssetImage('assets/images/instrucciones.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sigue estas sencillas instrucciones',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      // Contenedor para no desbordar texto
                      child: SizedBox(
                        width: 240,
                        child: Text(
                          'Aquí encontrarás un tour con instrucciones para '
                          'entender el procedimiento y realizar cada paso correctamente.',
                          style: GoogleFonts.outfit(
                            color: Colors.grey[300],
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.justify,
                          maxLines: 3,
                        ),
                      ),
                    ),
                    const Icon(
                      FontAwesomeIcons.circleChevronRight,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
