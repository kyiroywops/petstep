import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedWeightProvider = StateProvider<double>((ref) {
  return 0.0; // Valor inicial (por ejemplo, 0.0 kg)
});
