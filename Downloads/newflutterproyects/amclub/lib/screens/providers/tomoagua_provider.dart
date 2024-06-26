import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definimos un StateNotifier para gestionar el estado de tomar agua
class TomoAguaNotifier extends StateNotifier<bool> {
  TomoAguaNotifier() : super(false);

  void tomarAgua() {
    state = true;
  }

  void reset() {
    state = false;
  }
}

// Creamos el provider utilizando el TomoAguaNotifier
final tomoAguaProvider = StateNotifierProvider<TomoAguaNotifier, bool>((ref) {
  return TomoAguaNotifier();
});
