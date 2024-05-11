import "package:flutter/material.dart";

class AppTheme {
  ThemeData get themeData => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      primary: const Color(0xFF2a3745), // Azul Oscuro Profundo
      secondary: const Color(0xFF63675c), // Gris Verdoso
      surface: const Color(0xFF52544a), // Gris Pizarra
      background: const Color(0xFFdfbf8f), // Beige Suave
      error: const Color(0xFF875946), // Marrón Terracota
      onPrimary: const Color(0xFF46383b), // Marrón Oscuro
      onSecondary: const Color(0xFF1e1d25), // Negro Azabache
      onSurface: const Color(0xFF1e1d25), // Negro Azabache (repetido)
      onBackground: const Color(0xFF1e1d25), // Negro Azabache (repetido)
      onError: const Color(0xFF1e1d25), // Negro Azabache (puedes elegir otro si quieres variar)
    ),
    useMaterial3: true,
  );
}
