import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StateDialogInfo extends StatefulWidget {
  const StateDialogInfo({Key? key}) : super(key: key);

  @override
  State<StateDialogInfo> createState() => _StateDialogInfoState();
}

class _StateDialogInfoState extends State<StateDialogInfo> {
  final PageController _pageController = PageController();

  /// Variable para saber qué página está activa (0, 1 o 2).
  int _currentPage = 0;

  /// Datos para cada página: imagen, ícono, título y descripción.
  final List<_InfoPageData> _pagesData = [
    _InfoPageData(
      imagePath: 'assets/images/dialog1.jpg',
      icon: FontAwesomeIcons.checkCircle,
      title: 'Casos Enviados',
      description:
          'Son los casos que se han enviado con éxito y que sólo están guardados de manera local. '
          'Lo ideal es revisar que todos lleguen correctamente.',
    ),
    _InfoPageData(
      imagePath: 'assets/images/dialog2.jpg',
      icon: FontAwesomeIcons.bug,
      title: 'Casos Pendientes',
      description:
          'Son los casos que aún no se han subido por algún error o falta de conexión. '
          'La meta es que este número siempre esté en 0.',
    ),
    _InfoPageData(
      imagePath: 'assets/images/dialog3.jpg',
      icon: FontAwesomeIcons.paperPlane,
      title: 'Vista General',
      description:
          'Aquí puedes observar el estado de los casos enviados, pendientes y no enviados. '
          'Si ves algo inusual, intenta reintentar o comunícate con soporte.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Escuchamos los cambios de página para actualizar _currentPage
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ), 
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(40.0)),
        child: SizedBox(
          height: 600,
          child: Column(
            children: [
              // Parte superior: PageView (imágenes + icono + título + texto)
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pagesData.length,
                        itemBuilder: (context, index) {
                          final pageData = _pagesData[index];
                          return _buildInfoPage(pageData);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Indicador de puntitos
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pagesData.length,
                      effect: const WormEffect(
                        dotColor: Colors.grey,
                        activeDotColor: Colors.white,
                        dotHeight: 12,
                        dotWidth: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),

              // Botón de control (Siguiente / Salir)
              Padding(
                padding: const EdgeInsets.only(
                  top: 15.0,
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Si no es la última página, pasamos a la siguiente;
                    // si es la última, cerramos el diálogo
                    if (_currentPage < _pagesData.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentPage < _pagesData.length - 1
                        ? 'Siguiente'
                        : 'Salir', // Cambia la etiqueta según la página
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una página del PageView con el diseño deseado.
  Widget _buildInfoPage(_InfoPageData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Imagen expandida en la parte superior
        Expanded(
          child: Image.asset(
            data.imagePath,
            fit: BoxFit.cover,
          ),
        ),
        // Espacio
        const SizedBox(height: 20),
        // Ícono de info
        Icon(
          data.icon,
          color: Colors.white,
          size: 35,
        ),
        const SizedBox(height: 12),
        // Título
        Text(
          data.title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Descripción
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            data.description,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Clase auxiliar para manejar los datos de cada página:
/// imagen, ícono, título y descripción.
class _InfoPageData {
  final String imagePath;
  final IconData icon;
  final String title;
  final String description;

  const _InfoPageData({
    required this.imagePath,
    required this.icon,
    required this.title,
    required this.description,
  });
}
