import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DateTime> nextWeekDates = List.generate(7, (index) {
      DateTime today = DateTime.now();
      return today.add(Duration(days: index));
    });
      DateTime now = DateTime.now();
       DateTime startOfMonth = DateTime(now.year, now.month, 1);
       int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    return Scaffold(

     backgroundColor: Color.fromARGB(255, 27, 20, 18),
    
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            children: [
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Reemplaza con la ruta de tu logo.
                      height: 50, // Ajusta la altura según sea necesario.
                    ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.go('/login'); // Usando GoRouter para navegar.
            },
          ),
                   
                  ],
                ),
              ),
          
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile', // Título de la pantalla
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24, // Tamaño del texto
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
}
