import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingTutorialScreen extends StatefulWidget {
  const OnboardingTutorialScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingTutorialScreen> createState() =>
      _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

 final List<_SlideContent> slides = [
  _SlideContent(
    title: 'Registrar un nuevo caso',
    description:
        'Comienza por ingresar a la pantalla de inicio o a la sección de casos en la aplicación. Aquí podrás ver el botón "Registrar caso". Presiona este botón para iniciar el proceso de registro de un nuevo caso. Este paso te permitirá capturar toda la información necesaria para el registro.',
    imageAsset: 'assets/images/tutorial/1.png',
  ),
  _SlideContent(
    title: 'Seleccionar centro y jaula',
    description:
        'En este paso, debes seleccionar el centro de producción y la jaula correspondiente. Utiliza los botones laterales para desplazarte entre las opciones disponibles. Asegúrate de seleccionar el centro y la jaula correcta para el registro del caso. Una vez que estés seguro de tu selección, presiona el botón "Siguiente" para continuar.',
    imageAsset: 'assets/images/tutorial/2.png',
  ),
  _SlideContent(
    title: 'Ingresar peso del pescado',
    description:
        'Registra el peso del pescado que deseas registrar. Esto se hace ajustando el deslizador en la pantalla hasta que el valor mostrado coincida con el peso real del pescado. Este valor es crucial para completar el registro de manera precisa. Una vez seleccionado, presiona "Siguiente" para proceder.',
    imageAsset: 'assets/images/tutorial/3.png',
  ),
  _SlideContent(
    title: 'Tomar fotos del pescado',
    description:
        'Ahora es momento de tomar las fotos del pescado. Asegúrate de capturar imágenes claras y en orientación horizontal para facilitar el análisis posterior. Este paso es esencial, ya que las imágenes proporcionarán evidencia visual del caso registrado. Recuerda mantener la cámara estable mientras tomas las fotos.',
    imageAsset: 'assets/images/tutorial/4.png',
  ),
  _SlideContent(
    title: 'Revisar y subir fotos',
    description:
        'En esta pantalla, podrás revisar todas las fotos que has tomado. Si es necesario, puedes agregar fotos adicionales o reemplazar alguna que no sea adecuada. Una vez que estés satisfecho con las imágenes seleccionadas, presiona el botón "Terminar caso". Este paso asegurará que todas las fotos se carguen correctamente.',
    imageAsset: 'assets/images/tutorial/5.png',
  ),
  _SlideContent(
    title: 'Caso finalizado',
    description:
        'El caso ha sido registrado exitosamente y ahora se está subiendo a la base de datos. No necesitas esperar a que el proceso termine, ya que se realiza en segundo plano. Mientras tanto, puedes realizar otras acciones como registrar otro caso utilizando los mismos parámetros o volver a la pantalla de inicio.',
    imageAsset: 'assets/images/tutorial/6.png',
  ),
  _SlideContent(
    title: 'Pantalla de casos',
    description:
        'En la pantalla de casos, podrás consultar el estado de los casos registrados. Aquí verás los casos que aún no se han subido, los que están en proceso de carga y la información completa de los casos que ya han sido registrados. Esta sección es ideal para hacer un seguimiento detallado de todo el proceso.',
    imageAsset: 'assets/images/tutorial/7.png',
  ),
];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _continuePressed() {
    if (_currentPage == slides.length - 1) {
      // Última página -> ir a paywall
      context.go('/home');
    } else {
      // Avanzar a la siguiente slide
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  return _SliderItem(slide: slides[index]);
                },
              ),
            ),

            // INDICADOR de páginas
            SmoothPageIndicator(
              controller: _pageController,
              count: slides.length,
              effect: WormEffect(
                // Puedes usar distintos efectos
                dotHeight: 8,
                dotWidth: 8,
                spacing: 10,
                activeDotColor: Colors.white,
                dotColor: Colors.grey,
              ),
            ),

            // Espacio para separar el indicador del botón
            const SizedBox(height: 20),

            // Botón "Next"/"Salir"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _continuePressed,
                child: Text(
                  _currentPage == slides.length - 1 ? 'Salir' : 'Siguiente',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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

// Modelo simple para cada slide
class _SlideContent {
  final String title;
  final String description;
  final String imageAsset;

  _SlideContent({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}

// Widget para renderizar cada slide
class _SliderItem extends StatelessWidget {
  final _SlideContent slide;
  const _SliderItem({Key? key, required this.slide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int iconIndex = slide.imageAsset
        .replaceAll(RegExp(r'[^0-9]'), '') // Extrae el número del nombre del asset
        .isNotEmpty
        ? int.parse(slide.imageAsset.replaceAll(RegExp(r'[^0-9]'), ''))
        : 1;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen con bordes redondeados
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: 
 ClipRRect(
  borderRadius: BorderRadius.circular(32),
  child: FittedBox(
    fit: BoxFit.contain,
    child: Image.asset(slide.imageAsset),
  ),
),


            ),
          ),
          const SizedBox(height: 16),

          // Row con el ícono SVG y el título
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono SVG
              SvgPicture.asset(
                'assets/svg/$iconIndex.svg',
                height: 20, // Ajusta el tamaño del ícono según tu diseño
                color: Colors.white, // Aplica color si es necesario
              ),
              const SizedBox(width: 12), // Espaciado entre ícono y título

              // Título
              Text(
                slide.title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              slide.description,
              style: GoogleFonts.outfit(
                color: Colors.grey,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
