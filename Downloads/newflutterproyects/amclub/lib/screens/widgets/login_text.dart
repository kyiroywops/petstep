import "package:flutter/material.dart";

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(hintText: 'Usuario'),
            // Otras configuraciones del TextField
          ),
        ),
          SizedBox(height: 10), // Espaciado

              // Campo de contraseña
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(hintText: 'Contraseña', 
                  ),
                  obscureText: true,

                  // Otras configuraciones del TextField
                ),
              ),

      ],
    );
  }
}
