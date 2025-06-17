import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que verifica si hay conexión a Internet.
final isConnectedProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Obtener el estado inicial inmediatamente
  final initialResults = await connectivity.checkConnectivity();
  yield initialResults.any((result) => result != ConnectivityResult.none);
  
  // Luego escuchar cambios
  await for (final results in connectivity.onConnectivityChanged) {
    // Verifica si la lista de resultados contiene algún tipo de conexión diferente a 'none'.
    yield results.any((result) => result != ConnectivityResult.none);
  }
});

/// Provider que retorna una descripción en español del tipo de conexión activa.
final connectionTypeProvider = StreamProvider<String>((ref) async* {
  final connectivity = Connectivity();
  
  // Obtener el estado inicial inmediatamente
  final initialResults = await connectivity.checkConnectivity();
  final initialActiveConnection = initialResults.firstWhere(
    (result) => result != ConnectivityResult.none,
    orElse: () => ConnectivityResult.none,
  );
  yield _getConnectionDescription(initialActiveConnection);
  
  // Luego escuchar cambios
  await for (final results in connectivity.onConnectivityChanged) {
    final activeConnection = results.firstWhere(
      (result) => result != ConnectivityResult.none,
      orElse: () => ConnectivityResult.none,
    );
    yield _getConnectionDescription(activeConnection);
  }
});

String _getConnectionDescription(ConnectivityResult result) {
  switch (result) {
    case ConnectivityResult.mobile:
      return "Internet móvil";
    case ConnectivityResult.wifi:
      return "Wi-Fi";
    case ConnectivityResult.ethernet:
      return "Conexión por cable (Ethernet)";
    case ConnectivityResult.vpn:
      return "Conexión VPN";
    case ConnectivityResult.bluetooth:
      return "Conexión Bluetooth";
    case ConnectivityResult.other:
      return "Otro tipo de conexión";
    case ConnectivityResult.none:
    default:
      return "Sin conexión a Internet";
  }
}
