import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashBackToVerticalScreen extends ConsumerStatefulWidget {
  final String targetRoute;
  
  const SplashBackToVerticalScreen({
    super.key, 
    this.targetRoute = '/registros',
  });

  @override
  SplashBackToVerticalScreenState createState() => SplashBackToVerticalScreenState();
}

class SplashBackToVerticalScreenState extends ConsumerState<SplashBackToVerticalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    // Iniciar animación y transición
    _startTransition();
  }

  Future<void> _startTransition() async {
    // Iniciar la animación
    _animationController.forward();
    
    // Esperar un poco para que se vea el splash
    await Future.delayed(const Duration(milliseconds: 1400));
    
    // Cambiar a orientación vertical
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Pequeña pausa adicional para asegurar que la orientación se aplicó
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Navegar a la ruta objetivo
    if (mounted) {
      context.go(widget.targetRoute);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo con animación
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/splash.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Texto con animación
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Volviendo al inicio',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Indicador de carga
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Texto descriptivo
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Regresando a la\npantalla principal',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 