import 'package:fishbyte/presentation/providers/services/auth_service.dart';
import 'package:fishbyte/presentation/screens/casos_screen/ver_casos_recientes.dart';
import 'package:fishbyte/presentation/screens/basescreen.dart';
import 'package:fishbyte/presentation/screens/mortalidadextraida_screen.dart';
import 'package:fishbyte/presentation/screens/registrar_nuevo_caso/camara_por_dentro.dart';
import 'package:fishbyte/presentation/screens/casos_screen.dart';
import 'package:fishbyte/presentation/screens/home_page.dart';
import 'package:fishbyte/presentation/screens/home/instrucciones_screen.dart';
import 'package:fishbyte/presentation/screens/login/login_screen.dart';
import 'package:fishbyte/presentation/screens/registrar_nuevo_caso/registro_terminado_opciones.dart';
import 'package:fishbyte/presentation/screens/configuracion_screen.dart';
import 'package:fishbyte/presentation/screens/registrar_nuevo_caso/centrosSeleccion_horizontal.dart';
import 'package:fishbyte/presentation/screens/registrar_nuevo_caso/jaulaSeleccion_horizontal.dart';
import 'package:fishbyte/presentation/screens/registrar_nuevo_caso/weightSeleccion_horizontal.dart';
import 'package:fishbyte/presentation/screens/registrar_nuevo_caso/splash_orientation_screen.dart';
import 'package:fishbyte/presentation/screens/registrar_nuevo_caso/splash_back_to_vertical_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthCheckScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    ShellRoute(
        builder: (context, state, child) => BaseScreen(child: child),
        
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: '/registros',
            builder: (context, state) => FishPhotoSessionSetupScreen(),
          ), 
           GoRoute(
            path: '/mortalidadextraida',
            builder: (context, state) => MortalidadExtraidaScreen(),
          ), 
          GoRoute(path: '/configuracion', builder: (context, state) => SettingsScreen()),
        ],
    ),
    GoRoute(
      path: '/allrecents',
      builder: (context, state) => AllRecentsScreen(),
    ),
    GoRoute(
      path: ('/onboardingtutorial'),
      builder: (context, state) =>  OnboardingTutorialScreen(),
    ),

    // ruta horizontal app 
    GoRoute(
      path: '/splash-orientation',
      builder: (context, state) => SplashOrientationScreen(),
    ),

    GoRoute(
      path: '/splash-back-to-vertical',
      builder: (context, state) {
        final targetRoute = state.uri.queryParameters['target'] ?? '/registros';
        return SplashBackToVerticalScreen(targetRoute: targetRoute);
      },
    ),

    GoRoute(
      path: '/centerselection',
      builder: (context, state) => HorizontalCenterSelection(),
    ),

    GoRoute(
      path: '/jaulaselection',
      builder: (context, state) => HorizontalCageSelector(),
      ),

    GoRoute(
      path: '/weightselection',
      builder: (context, state) => HorizontalWeightSelection(),
    ),

    GoRoute(
      path: '/fullscreenCamera',
      builder: (context, state) => FishPhotoSessionFullScreen(),
    ),

    GoRoute(
      path: '/registroterminadoopciones',
      builder: (context, state) => RegistroTerminadoOpciones(),
    ),

  ],
);
