import 'package:fishbyte/config/router/app_router.dart';
import 'package:fishbyte/config/theme/app_theme.dart';
import 'package:fishbyte/presentation/providers/login/auth_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:fishbyte/presentation/providers/login/centers_provider.dart';
import 'package:fishbyte/presentation/providers/upload_queue_provider.dart';

// Constantes para los IDs de cliente de Google
const String kGoogleWebClientId = '42667538144-m16ia0f63i8lr5qccvnif9uisa7ur1e0.apps.googleusercontent.com';
const String kGoogleIOSClientId = '42667538144-ckdb28nib5n7k70vtujbpsv21u6q8g5j.apps.googleusercontent.com';

Future<void> main() async {
  // Inicializa Sentry envolviendo toda la configuración
  await SentryFlutter.init(
    (options) {
      // Tu DSN de Sentry (esto es para el manejo de errores)
      options.dsn = 'https://b88072e6a8be099f2ff34ae2ef7fce4a@o4508609725792256.ingest.us.sentry.io/4508614820691968';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    // appRunner se llama una vez que Sentry está listo
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Cargar variables de entorno
      // await dotenv.load(fileName: ".env");
      
      // Inicializar Supabase con valores directos
      await Supabase.initialize(
        url: 'https://hjkmzymjrnzkedktwgsc.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhqa216eW1qcm56a2Vka3R3Z3NjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM3ODU5ODIsImV4cCI6MjA1OTM2MTk4Mn0.FYbkALKSDN9X138rfduUmtRd4ut8DPHdIlrS9hFhJgk',
      );

      // Forzar orientación vertical
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // Leer SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedUrl = prefs.getString('enterpriseUrl');

      // En lugar de usar ProviderScope(...) directamente,
      // creamos un container manual para poder invocar providers luego de runApp
      final container = ProviderContainer(
        overrides: [
          // Proporcionamos el cliente de Supabase para que esté disponible en toda la app
          supabaseClientProvider.overrideWithValue(Supabase.instance.client),
          
          if (storedUrl != null)
            selectedCenterValueProvider.overrideWith(
              (ref) => storedUrl,
            ),
        ],
      );

      // Iniciar la app con Riverpod
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      );

      // OBTENEMOS EL PROVIDER DE LA UPLOAD QUEUE para que se inicialice
      container.read(uploadQueueProvider.notifier); 
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FishByte',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme().themeData,
    );
  }
}
