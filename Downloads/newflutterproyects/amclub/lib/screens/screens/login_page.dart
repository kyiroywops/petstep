import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
// Asegúrate de tener los paquetes necesarios para la autenticación de Google y Facebook.

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  bool isEmailEntered = false;
  bool _passwordVisible = false;

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double frostedContainerTopPosition =
        MediaQuery.of(context).size.height * 0.3;
    double paddingVertical = 20; // El padding vertical de tu contenedor
    double titleTopPosition =
        frostedContainerTopPosition - 60; // Sube el título más arriba

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Fondo con imagen
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Botón para retroceder
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            top: titleTopPosition -
                110, // Ajusta la posición vertical según sea necesario
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png', // Ruta del logo
                height: 100, // Ajusta el tamaño según tus necesidades
              ),
            ),
          ),
          Positioned(
            top: titleTopPosition,
            left: 55,
            child: isEmailEntered
                ? Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            isEmailEntered =
                                false; // Esto permitirá al usuario volver al estado anterior
                          });
                        },
                      ),
                      Text(
                        'Log in',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  )
                : Text('Hi!',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Outfit',
                        fontSize: 40,
                        fontWeight: FontWeight.w900)),
          ),
          // Container con efecto "frosted"
          Positioned(
              top:
                  frostedContainerTopPosition, // Posición calculada para el contenedor
              left: 20,
              right: 20, // Agrega esto para tener un margen en ambos lados
              child: ClipRRect(
                // Asegura que el filtro se aplique dentro de los bordes redondeados
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5,
                      sigmaY:
                          5), // Ajusta los valores de sigma para aumentar o disminuir el efecto de desenfoque
                  child: Container(
                    padding: EdgeInsets.fromLTRB(30, 25, 30, 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(
                          0.1), // Cambia el color aquí a gris con cierta transparencia
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: <Widget>[
                        if (!isEmailEntered) ...[
                         TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Please enter a valid email address.';
    }
    return null;
  },
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  cursorColor: Colors.black, // Color del cursor
  style: TextStyle(
    fontSize: 12,
    fontFamily: 'Outfit',
    color: Colors.grey.shade900,
    fontWeight: FontWeight.w600
  ),

  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    hintText: 'Email',
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Ajusta el padding aquí para reducir la altura
    // Personaliza la apariencia del borde en foco
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Colors.black, // Borde negro cuando el TextField está en foco
        width: 3.0, // Grosor del borde
      ),
    ),
    // Personaliza la apariencia del borde cuando el TextField está sin foco
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Colors.grey[200]!, // Borde gris claro en el estado normal
        width: 1.0, // Grosor estándar del borde
      ),
    ),
  ),
),
                          SizedBox(height: 20),
                          ElevatedButton(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                  color: Colors.grey[200],
                                  fontSize: 12,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700), // Texto blanco

                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Fondo negro
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.38),
                              disabledBackgroundColor: Colors.grey.withOpacity(
                                  0.12), // Color del botón cuando está deshabilitado o en press
                              minimumSize: Size(double.infinity,
                                  40), // Ancho máximo y alto fijo
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical:
                                      18), // Padding vertical para que coincida con la altura del TextField
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Mismo radio de borde que el TextField
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isEmailEntered =
                                    true; // Actualiza el estado para mostrar el campo de contraseña
                              });
                            },
                          ),
                        ] else ...[
                          TextField(
                              style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Outfit',
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w600
                          ),

                            controller: passwordController,

                            keyboardType: TextInputType.text,
                            obscureText:
                                !_passwordVisible, // Determina si el texto debe ser oscurecido
                            obscuringCharacter:
                                '●', // Utiliza un carácter de círculo más grande
                            cursorColor: Colors.black, // Color del cursor
                            decoration: InputDecoration(
                              
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 15, 20, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                  child: Text(
                                    _passwordVisible ? "Hide" : "View",
                                      style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Outfit',
                                      color: Colors.grey.shade900,
                                      fontWeight: FontWeight.w800
                                    ),

                                  ),
                                ),
                              ),
                              
                              filled: true,
                              fillColor: Colors.grey[300],
                              hintText: 'Password',
                              // Ajustes adicionales para la apariencia del borde
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: Colors
                                      .black, // Borde verde cuando el TextField está en foco
                                  width: 3.0, // Grosor del borde
                                ),
                              ),
                              
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: Colors.grey[
                                      200]!, // Borde gris claro en el estado normal
                                  width: 1.0, // Grosor estándar del borde
                                ),
                              ),
                              // Ajustes para el texto de sugerencia, color de relleno, etc.
                            ),
                          
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[200]), // Texto blanco
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Fondo negro
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.38),
                              disabledBackgroundColor: Colors.grey.withOpacity(
                                  0.12), // Color del botón cuando está deshabilitado o en press
                              minimumSize: Size(double.infinity,
                                  52), // Ancho máximo y alto fijo
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical:
                                      0), // Padding vertical para que coincida con la altura del TextField
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Mismo radio de borde que el TextField
                              ),
                            ),
                            onPressed: () async {
                              if (emailController.text.contains('@')) {
                                try {
                                  print(
                                      'Intentando iniciar sesión con correo: ${emailController.text}');
                                  UserCredential userCredential =
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  print('Inicio de sesión exitoso');
                                  if (mounted) {
                                    context.go(
                                        '/basescreen'); // Assuming GoRouter is set up properly
                                  }
                                } on FirebaseAuthException catch (e) {
                                  print('Error de Firebase Auth: ${e.code}');
                                  if (e.code == 'user-not-found') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'No user found for that email.')));
                                  } else if (e.code == 'wrong-password') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Wrong password provided for that user.')));
                                  }
                                }
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  // Acción para navegar a Forgot your password
                                },
                                child: Text(
                                  "Forgot your password?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[200],
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets
                                      .zero, // Remueve el padding para alinear el texto
                                  alignment: Alignment
                                      .centerLeft, // Alinea el texto a la izquierda
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (!isEmailEntered) ...[
                          SizedBox(
                              height:
                                  20), // Espacio entre el botón 'Continue' y el texto 'or'
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    80.0), // Ajusta este valor según tus necesidades
                            child: Center(
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey[900],
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  20), // Espacio entre el texto 'or' y los botones de autenticación social
                          SizedBox(
                            width: double
                                .infinity, // Esto hará que el botón se expanda al ancho del contenedor
                            child: TextButton.icon(
                              icon: SvgPicture.asset(
                                'assets/icons/facebook.svg', // Asegúrate de que la ruta del asset es correcta
                                width: 24.0,
                                height: 24.0,
                              ),
                              label: Text(
                                'Continue with Facebook',
                                style: TextStyle(
                                  color: Colors.grey[200],
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors
                                    .blue, // El color de fondo de Facebook
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        15.0), // Alinea el padding vertical con el botón "Continue"
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ), // El color del texto e icono cuando se presiona el botón
                              ),
                              onPressed: () {
                                // Tu lógica de autenticación con Facebook aquí
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              width: double
                                  .infinity, // Esto hará que el botón se expanda al ancho del contenedor
                              child: TextButton.icon(
                                icon: SvgPicture.asset(
                                  'assets/icons/google.svg', // Asegúrate de que la ruta del asset es correcta
                                  width: 24.0,
                                  height: 24.0,
                                ),
                                label: Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: Colors.grey[900],
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.grey[
                                      200], // El color de fondo de Facebook
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          15.0), // Alinea el padding vertical con el botón "Continue"
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ), // El color del texto e icono cuando se presiona el botón
                                ),
                                onPressed: (
                                  
                                ) {
                                  // Tu lógica de autenticación con Facebook aquí
                                },
                              ),
                            ),
                          ),
                        

                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Alinea los widgets a la izquierda
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // Acción para navegar al registro
                                      },
                                      child: Text(
                                        "Sign up",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.brown[500],
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Acción para navegar a Forgot your password
                                  },
                                  child: Text(
                                    "Forgot your password?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.brown[500],
                                      fontSize: 12,

                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets
                                        .zero, // Remueve el padding para alinear el texto
                                    alignment: Alignment
                                        .centerLeft, // Alinea el texto a la izquierda
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
