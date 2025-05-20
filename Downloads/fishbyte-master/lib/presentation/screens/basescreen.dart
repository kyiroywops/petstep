import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BaseScreen extends StatefulWidget {
  final Widget child;

  const BaseScreen({required this.child, Key? key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 27, 27, 31),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem('assets/svg/homebasescreen.svg', 'Inicio', 1, '/home'),
            _buildNavItem('assets/svg/camerabasescreen.svg', 'Casos', 2, '/registros'),
             _buildNavItem('assets/svg/graphbase.svg', 'Mortalidad', 3, '/mortalidadextraida'),
            _buildNavItem('assets/svg/settingsbasescreen.svg', 'Configuración', 4, '/configuracion'),
          ],
        ),
      ),
    );
  }

    Widget _buildNavItem(String svgPath, String label, int index, String route,) {
        bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
       HapticFeedback.lightImpact();

        setState(() => _selectedIndex = index);
        context.go(route); // Usa GoRouter para cambiar de pantalla
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              svgPath,
              width: 26,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
