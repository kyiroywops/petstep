import 'package:fishbyte/presentation/providers/photos_state_provider.dart';
import 'package:fishbyte/presentation/providers/recentlysent_provider.dart';
import 'package:fishbyte/presentation/providers/senttotal_counter_provider.dart';
import 'package:fishbyte/presentation/providers/reports_provider.dart';
import 'package:fishbyte/presentation/widgets/casos_screen/casos_no_enviados_widget.dart';
import 'package:fishbyte/presentation/widgets/casos_screen/recentlysent_widget.dart';
import 'package:fishbyte/presentation/widgets/casos_screen/top_status_bar_widget.dart';
import 'package:fishbyte/presentation/widgets/upload_queue_bar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FishPhotoSessionSetupScreen extends ConsumerStatefulWidget {
  const FishPhotoSessionSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FishPhotoSessionSetupScreen> createState() =>
      _FishPhotoSessionSetupScreenState();
}

class _FishPhotoSessionSetupScreenState
    extends ConsumerState<FishPhotoSessionSetupScreen> {
  // Controlador para gestionar el refresco
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // Método que se llama al hacer pull-to-refresh
  Future<void> _onRefresh() async {
    try {
      // Invalidamos los providers para que recarguen
      ref.invalidate(allReportsProvider);
      await ref.read(allReportsProvider.future);

      ref.invalidate(recentlySentProvider);
      await ref.read(recentlySentProvider.future);

      ref.invalidate(sentCounterProvider);
      await ref.read(sentCounterProvider.future);
    } catch (e) {
      debugPrint("Error durante el refresh: $e");
    } finally {
      // Indicar al RefreshController que hemos terminado
      _refreshController.refreshCompleted();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // -----------
            // CONTENIDO PRINCIPAL con SmartRefresher
            // -----------
            SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              enablePullUp: false, // si no usas "pull-up to load more"
              
              // "header" para mostrar un indicador estilo iOS en ambas plataformas
              header: CustomHeader(
                builder: (BuildContext context, RefreshStatus? status) {
                  // Ajusta el diseño según el estado: "idle", "canRefresh", "refreshing", etc.
                  Widget body;
                  switch (status) {
                    case RefreshStatus.canRefresh:
                      // body =  Text("Suelta para refrescar...", style: GoogleFonts.outfit(fontSize: 11, color: Colors.white));
                      body = const CupertinoActivityIndicator();
                      break;
                    case RefreshStatus.refreshing:
                      body = const CupertinoActivityIndicator();
                      break;
                    case RefreshStatus.idle:
                    default:
                    body = const CupertinoActivityIndicator();
                      // body =  Text("Desliza hacia abajo para refrescar...", style: GoogleFonts.outfit(fontSize: 11, color: Colors.white));
                      break;
                  }
                  return SizedBox(
                    height: 60.0,
                    child: Center(child: body),
                  );
                },
              ),

              // Este será el scroll principal: tu CustomScrollView con Slivers
              child: CustomScrollView(
                // Si quieres forzar scroll siempre:
                // physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 2) Barra con progreso de subidas
                  const SliverToBoxAdapter(
                    child: UploadQueueBar(),
                  ),

                  // 3) Un poco de espacio
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // 4) Barra superior de estado (nuevo widget)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TopStatusBarWidget(),
                    ),
                  ),

                  // 5) Sección: “Registros enviados recientemente”
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: RecentlySentWidget(
                        title: "Casos enviados recientemente",
                      ),
                    ),
                  ),

                  // 6) Sección: “Registros no enviados”
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: NotSentReportsWidget(),
                    ),
                  ),

                  // 7) Espacio extra
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),

            // -----------
            // BOTÓN FIJO ABAJO
            // -----------
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Redireccionar a la pantalla de selección de centros
                  ref.read(photoSessionProvider.notifier).reset();
                  context.go('/centerselection');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Registrar nuevo caso",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade900,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}