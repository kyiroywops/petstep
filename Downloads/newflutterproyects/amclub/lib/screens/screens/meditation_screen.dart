import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MeditationScreen extends StatefulWidget {
  MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MeditationScreen> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: SingleChildScrollView(  // Permite hacer scroll en todo el contenido
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 50,
                    ),
                    Row(
                      children: [
                        Text(
                          '0',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade300, fontFamily: 'HindMurai', fontWeight: FontWeight.w800),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            FontAwesomeIcons.fire,
                            color: Colors.redAccent.shade100,
                            size: 19,
                          ),
                        ),
                        
                       
                      ],
                    ),
                    
                  ],
                ),
              ),
            

            ],
          ),
        ),
      ),
    );
  }
}

