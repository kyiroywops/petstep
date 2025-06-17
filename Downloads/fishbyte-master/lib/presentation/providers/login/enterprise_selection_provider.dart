import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishbyte/presentation/controllers/login_controller.dart';

// Estado para las empresas disponibles
final enterprisesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final loginController = ref.read(loginControllerProvider.notifier);
  return await loginController.getAllEnterprises();
});

// Estado para la empresa seleccionada
final selectedEnterpriseProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Estado para mostrar el login de Google después de seleccionar empresa
final showGoogleLoginProvider = StateProvider<bool>((ref) => false); 