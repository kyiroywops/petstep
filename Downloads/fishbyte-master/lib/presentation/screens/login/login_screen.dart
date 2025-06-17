import 'package:fishbyte/presentation/controllers/login_controller.dart';
import 'package:fishbyte/presentation/providers/login/enterprise_selection_provider.dart';
import 'package:fishbyte/presentation/widgets/login/enterprise_selection_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);
    final showGoogleLogin = ref.watch(showGoogleLoginProvider);
    final selectedEnterprise = ref.watch(selectedEnterpriseProvider);

    // Escucha del estado para mostrar SnackBar en caso de error o navegar si hay éxito.
    ref.listen<AsyncValue<void>>(loginControllerProvider, (previous, next) {
      if (next is AsyncError) {
        // Mostrar un SnackBar con el mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } else if (next is AsyncData) {
        // Si la autenticación fue exitosa, revisar si realmente estamos autenticados
        Future.microtask(() async {
          final isAuth = await ref.read(loginControllerProvider.notifier).isAuthenticated();
          if (isAuth) {
            debugPrint("Login exitoso. Redirigiendo a home...");
            if (context.mounted) {
              context.go('/home');
            }
          }
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen que cubre toda la pantalla
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondologin.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // SingleChildScrollView para que todo el contenido sea desplazable
          SingleChildScrollView(
            child: ConstrainedBox(
              // Esto obliga a que la vista ocupe al menos toda la altura de la pantalla
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              // IntrinsicHeight + Expanded para que la parte blanca llene el resto
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),

                    // Logo en el centro
                    Center(
                      child: Image.asset(
                        'assets/images/logo.webp',
                        width: 260,
                      ),
                    ),

                    const SizedBox(height: 100),

                    // Expanded para que, si hay espacio, el contenedor blanco llene el resto
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 15),
                            Text(
                              'Bienvenido',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            Text(
                              showGoogleLogin ? 
                                'Inicia sesión con tu cuenta de Google' :
                                'Selecciona tu empresa para continuar',
                              style: GoogleFonts.outfit(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 10),

                            // Mostrar selección de empresa o botón de Google según el estado
                            if (!showGoogleLogin) 
                              // Widget de selección de empresa
                              const EnterpriseSelectionWidget()
                            else
                              // Botón Google y lógica relacionada
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  // Mostrar empresa seleccionada
                                  if (selectedEnterprise != null)

                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(FontAwesomeIcons.solidBuilding, color: Colors.blueAccent, size: 15),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${selectedEnterprise!['name']}',
                                              style: GoogleFonts.outfit(
                                                color: Colors.blueAccent,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              // Regresar a selección de empresa
                                              ref.read(showGoogleLoginProvider.notifier).state = false;
                                              ref.read(selectedEnterpriseProvider.notifier).state = null;
                                            },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // cambiar empresa
                                                    Text(
                                                      'Cambiar empresa',
                                                      style: GoogleFonts.outfit(
                                                        color: Colors.blueAccent,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Icon(FontAwesomeIcons.solidPenToSquare, color: Colors.blueAccent, size: 15),
                                                  ],
                                                ),
                                              ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Botón Google
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 60,
                                      child: ElevatedButton.icon(
                                        icon: SvgPicture.asset(
                                          'assets/icons/google.svg',
                                          width: 24.0,
                                          height: 24.0,
                                        ),
                                        label: Text(
                                          'Iniciar sesión con Google',
                                          style: GoogleFonts.outfit(
                                            color: Colors.grey[900],
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          elevation: 2,
                                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                            side: BorderSide(color: Colors.grey.shade300),
                                          ),
                                        ),
                                        onPressed: (loginState is AsyncLoading || selectedEnterprise == null)
                                          ? null  // Deshabilitar el botón durante la carga o si no hay empresa
                                          : () async {
                                              HapticFeedback.lightImpact();
                                              try {
                                                debugPrint("Pulsando botón de inicio de sesión con Google para empresa: ${selectedEnterprise!['id']}");
                                                // Llamar al controlador para iniciar sesión con Google y la empresa seleccionada
                                                await ref.read(loginControllerProvider.notifier)
                                                         .signInWithGoogle(selectedEnterprise!['id'].toString());
                                              } catch (e) {
                                                debugPrint("Error en botón de login: $e");
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Error al iniciar sesión: $e"),
                                                    backgroundColor: Colors.red[700],
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              }
                                            },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Estado de carga si está ocurriendo
                                  if (loginState is AsyncLoading)
                                    Column(
                                      children: [
                                        const Center(
                                          child: CupertinoActivityIndicator(),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Iniciando sesión con Google...\nVerificando acceso a ${selectedEnterprise!['name']}',
                                          style: GoogleFonts.outfit(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),

                                  // Si hay un error, mostrar mensaje
                                  if (loginState is AsyncError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Error: ${loginState.error}',
                                        style: GoogleFonts.outfit(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),

                            // Términos y Políticas (siempre visibles)
                            Padding(
                              // padding depende si es antes o despues de la seleccion de empresa
                              padding: showGoogleLogin ? const EdgeInsets.only(top: 5) : const EdgeInsets.only(top: 10),
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: Colors.grey.shade400,
                                    ),
                                    children: [
                                      const TextSpan(text: "Al iniciar sesión, aceptas nuestros "),
                                      TextSpan(
                                        text: "Términos de servicio",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                          final url = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula');
                                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                            throw 'No se pudo abrir $url';
                                          }
                                        },
                                      ),
                                      const TextSpan(text: " y confirmas que has revisado nuestra "),
                                      TextSpan(
                                        text: "Política de privacidad,",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                         ..onTap = () async {
                                          final url = Uri.parse('https://gostatsog.github.io/Fishbyte_policies');
                                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                            throw 'No se pudo abrir $url';
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
