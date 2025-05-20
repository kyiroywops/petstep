import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Muestra la info del usuario (Username, Empresa, Rol)
class UserInfoWidget extends StatelessWidget {
  final String? username;
  final String? enterpriseName;
  final String? roleName;

  const UserInfoWidget({
    Key? key,
    this.username,
    this.enterpriseName,
    this.roleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (username == null && enterpriseName == null && roleName == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos del usuario',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Divider(color: Colors.grey[800]),

            // Username
            if (username != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Usuario',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    username!,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),

            // Empresa
            if (enterpriseName != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Empresa',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    enterpriseName!,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),

            // Rol
            if (roleName != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rol',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    roleName!,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
