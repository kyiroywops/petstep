import "package:flutter/material.dart";

class AppTheme {
  ThemeData get themeData => ThemeData(
      splashFactory: NoSplash.splashFactory, // Esto elimina el efecto splash
    highlightColor: Colors.transparent, // Esto elimina el color al mantener presionado
    scaffoldBackgroundColor: const Color.fromARGB(255, 17, 17, 17),
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      primary: const Color(0xFF2a3745), // Azul Oscuro Profundo
      secondary: const Color(0xFF63675c), // Gris Verdoso
      surface: const Color(0xFF52544a), // Gris Pizarra
      error: const Color(0xFF875946), // Marrón Terracota
      onPrimary: const Color(0xFF46383b), // Marrón Oscuro
      onSecondary: const Color(0xFF1e1d25), // Negro Azabache
      onSurface: const Color(0xFF1e1d25), // Negro Azabache (repetido)
      onError: const Color(0xFF1e1d25), // Negro Azabache (puedes elegir otro si quieres variar)
    ),
    useMaterial3: true,
  );
}
