import 'package:fishbyte/presentation/providers/services/bluetooth_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fishbyte/presentation/providers/user_info_provider.dart';
import 'package:fishbyte/presentation/widgets/home/informacion_estados_widget.dart';
import 'package:fishbyte/presentation/widgets/home/short_cut_instrucciones_widget.dart';
import 'package:fishbyte/presentation/widgets/home/short_cut_registranuevocaso_widget.dart';
import 'package:fishbyte/presentation/widgets/home/user_info_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el provider que carga los datos del usuario
    final userInfoAsync = ref.watch(userInfoProvider);

    // `userInfoAsync` es un AsyncValue<Map<String, dynamic>>
    // Usamos when() para manejar loading, error y data
    return userInfoAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text('Error al cargar datos: $error')),
      ),
      data: (userMap) {
        // Extraemos los valores del mapa
        final username = userMap['username'] as String?;
        final enterpriseName = userMap['enterpriseName'] as String?;
        final roleName = userMap['roleName'] as String?;

        // Construimos la pantalla final con esos datos
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 27, 27, 31),
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.webp', height: 30),
                const SizedBox(width: 20),
                Image.asset('assets/images/lythium.webp', height: 30),
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                child: Column(
                  children: [
                
                    // Sección: Atajo para registrar nuevo caso
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ShortCutRegistros(
                        username: username,
                        enterpriseName: enterpriseName,
                        roleName: roleName,
                      ),
                    ),
                
                    // Sección: Datos de usuario
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: UserInfoWidget(
                        username: username,
                        enterpriseName: enterpriseName,
                        roleName: roleName,
                      ),
                    ),
                
                    // Sección: Instrucciones
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ShortCutInstruccionesWidget(
                        username: username,
                        enterpriseName: enterpriseName,
                        roleName: roleName,
                      ),
                    ),
                
                    // Sección: Información de estados (usa los providers de conteo)
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InformacionEstadosWidget(
                        username: username,
                        enterpriseName: enterpriseName,
                        roleName: roleName
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: BleTestStandaloneWidget(),
                  ),
                
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
