import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fishbyte/presentation/providers/login/enterprise_selection_provider.dart';

class EnterpriseSelectionWidget extends ConsumerWidget {
  const EnterpriseSelectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enterprisesAsync = ref.watch(enterprisesProvider);
    final selectedEnterprise = ref.watch(selectedEnterpriseProvider);

    return enterprisesAsync.when(
      data: (enterprises) {
        if (enterprises.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
            const SizedBox(height: 10),
            Text(
              'Selecciona tu empresa',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Elige la empresa con la que deseas iniciar sesión',
              style: GoogleFonts.outfit(
                color: Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Lista de empresas
            ...enterprises.map((enterprise) => _buildEnterpriseCard(
              context,
              ref,
              enterprise,
              selectedEnterprise?.containsKey('id') == true && 
              selectedEnterprise!['id'] == enterprise['id'],
            )).toList(),
            
            const SizedBox(height: 20),
            
            // Botón para continuar (solo si hay empresa seleccionada)
            if (selectedEnterprise != null)
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(showGoogleLoginProvider.notifier).state = true;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Continuar con ${selectedEnterprise['name']}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEnterpriseCard(
    BuildContext context, 
    WidgetRef ref, 
    Map<String, dynamic> enterprise,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          ref.read(selectedEnterpriseProvider.notifier).state = enterprise;
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.grey[50],
            border: Border.all(
              color: isSelected ? Colors.blueAccent.withOpacity(0.8) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enterprise['name'] ?? 'Sin nombre',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (enterprise['nickname'] != null && 
                        enterprise['nickname'].toString().isNotEmpty)
                      const SizedBox(height: 4),
                    if (enterprise['nickname'] != null && 
                        enterprise['nickname'].toString().isNotEmpty)
                      Text(
                        enterprise['nickname'],
                        style: GoogleFonts.outfit(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  FontAwesomeIcons.solidCircleCheck,
                  color: Colors.blueAccent,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const CupertinoActivityIndicator(),
        const SizedBox(height: 16),
        Text(
          'Cargando empresas disponibles...',
          style: GoogleFonts.outfit(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red[400],
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Error al cargar empresas',
          style: GoogleFonts.outfit(
            color: Colors.red[600],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: GoogleFonts.outfit(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.business_outlined,
          color: Colors.grey[400],
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'No hay empresas disponibles',
          style: GoogleFonts.outfit(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Contacta al administrador para obtener acceso',
          style: GoogleFonts.outfit(
            color: Colors.grey[500],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 