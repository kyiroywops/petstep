import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Widget que muestra la fecha/hora en el formato:
/// "23:32 hrs • 2024/12/01" pero convertido a la hora local
class DisplayCleanDate extends StatelessWidget {
  final String isoDate;

  const DisplayCleanDate({
    Key? key,
    required this.isoDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime dateTime;
    try {
      // 1) Parseamos la fecha/hora como UTC si viene con 'Z' en el string
      dateTime = DateTime.parse(isoDate);
    } catch (_) {
      // Si falla, puedes retornar un texto fallback
      return const Text(
        '',
        style: TextStyle(color: Colors.white, fontSize: 10),
      );
    }

    // 2) Convertimos a la hora local
    final localDateTime = dateTime.toLocal();

    // 3) Formateamos la hora y fecha en local
    final timeStr = DateFormat('HH:mm').format(localDateTime);     
    final dateStr = DateFormat('yyyy/MM/dd').format(localDateTime); 
    final displayText = "$timeStr hrs • $dateStr";

    return Text(
      displayText,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 10,
      ),
    );
  }
}
