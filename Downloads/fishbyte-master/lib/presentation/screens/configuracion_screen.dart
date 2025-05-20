import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:fishbyte/presentation/widgets/settings/settings_footer.dart';
import 'package:fishbyte/presentation/widgets/settings/settings_item.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  /// Función auxiliar para abrir URLs
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir la URL: $url');
    }
  }

  /// Abre un diálogo para que el usuario describa el error y lo envía a Sentry
  void _reportError(BuildContext context) {
    // Controlador para el campo de texto
    final TextEditingController errorTextController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            'Reportar un error',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: errorTextController,
            maxLines: 4,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w300),  
            decoration: InputDecoration(
              hintText: 'Describe el error que experimentaste...',
              hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancelar',
                style: GoogleFonts.outfit(color: Colors.redAccent.shade400, fontSize: 11,),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () async {
                final userDescription = errorTextController.text.trim();
                Navigator.pop(ctx); // Cerrar el diálogo

                if (userDescription.isNotEmpty) {
                  // Envío básico a Sentry como un mensaje
                  // (puedes usar Sentry.captureException para capturar excepciones, etc.)
                  await Sentry.captureMessage('Reporte de error del usuario: $userDescription');

                  // Aquí podrías mostrar un SnackBar o similar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '¡Gracias por reportar el error!',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      backgroundColor: Colors.greenAccent.shade400,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Enviar',
                style: GoogleFonts.outfit(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        // Envuelve la Column en un SingleChildScrollView
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                /// Contenedor con los ítems de configuración
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(
                          'Configuración',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // // Ítems de configuración
                        // SettingsItem(
                        //   svgPath: 'assets/svg/person.svg',
                        //   title: 'Cuenta',
                        //   subtitle: 'Información personal, cuentas vinculadas',
                        //   onTap: () {
                        //     HapticFeedback.lightImpact();
                        //     // Navegar a la sección de Cuenta
                        //   },
                        // ),
                        SettingsItem(
                          svgPath: 'assets/svg/info.svg',
                          title: 'Políticas de Privacidad',
                          subtitle: 'Lee nuestras políticas y condiciones',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _launchUrl('https://gostatsog.github.io/Fishbyte_policies');
                          },
                        ),
                        SettingsItem(
                          svgPath: 'assets/svg/terms.svg',
                          title: 'Términos de Servicio',
                          subtitle: 'Conoce nuestros términos',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // Ajusta la URL si es distinta
                            _launchUrl('https://www.apple.com/legal/internet-services/itunes/dev/stdeula');
                          },
                        ),
                        SettingsItem(
                          svgPath: 'assets/svg/mensaje.svg',
                          title: 'Soporte',
                          subtitle: 'Contáctanos por nuestro sitio web',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _launchUrl('https://lythium.cl/');
                          },
                        ),
                        SettingsItem(
                          svgPath: 'assets/svg/bug.svg',
                          title: 'Reportar un error',
                          subtitle: 'Ayúdanos a mejorar la experiencia',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // Muestra un diálogo interno para capturar el reporte
                            _reportError(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                /// Footer (logo, versión, botón cerrar sesión, etc.)
                const SettingsFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
