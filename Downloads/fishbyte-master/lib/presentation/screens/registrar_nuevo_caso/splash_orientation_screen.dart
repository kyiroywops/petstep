import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashOrientationScreen extends ConsumerStatefulWidget {
  const SplashOrientationScreen({super.key});

  @override
  SplashOrientationScreenState createState() => SplashOrientationScreenState();
}

class SplashOrientationScreenState extends ConsumerState<SplashOrientationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // Iniciar animación y transición
    _startTransition();
  }

  Future<void> _startTransition() async {
    // Iniciar la animación
    _animationController.forward();
    
    // Esperar un poco para que se vea el splash
    await Future.delayed(const Duration(milliseconds: 1800));
    
    // Cambiar a orientación horizontal
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
    
    // Pequeña pausa adicional para asegurar que la orientación se aplicó
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Navegar a la selección de centros
    if (mounted) {
      context.go('/centerselection');
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
                        width: 120,
                        height: 120,
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
                  
                  const SizedBox(height: 40),
                  
                  // Texto con animación
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Preparando registro',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Indicador de carga
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Texto descriptivo
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Configurando pantalla para\nuna mejor experiencia',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.grey.shade400,
                          fontSize: 13,
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