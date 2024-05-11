import 'package:amclub/screens/screens/home_page.dart';
import 'package:amclub/screens/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Historial
        Text('Calendario', textAlign: TextAlign.center), // Calendario
       ProfileScreen()  
            
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(FontAwesomeIcons.house, 'Home', 0),
            _buildNavItem(FontAwesomeIcons.solidStarHalfStroke, 'Stats', 1),
            _buildNavItem(FontAwesomeIcons.solidCircleUser, 'Profile', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      splashColor: Colors.transparent, // Removes ripple effect
      highlightColor: Colors.transparent, // Removes highlight effect
      child: Container(
        width: 60, // Ancho para cada botón de icono
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 27, color: _selectedIndex == index ? Colors.grey.shade300 : Colors.grey.shade600),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(label, style: TextStyle(color: _selectedIndex == index ? Colors.grey.shade300 : Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'HindMurai')),
            ),
          ],
        ),
      ),
    );
  }

 

}
