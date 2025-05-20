import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Este provider lee el contador 'registrosEnviadosTotales' de SharedPreferences.
/// Si no existe, retorna 0.
final sentCounterProvider = FutureProvider<int>((ref) async {
  final sp = await SharedPreferences.getInstance();
  // Por defecto 0 si no existe
  return sp.getInt('registrosEnviadosTotales') ?? 0;
});

/// Método helper para incrementar en +1
Future<void> incrementSentCounter() async {
  final sp = await SharedPreferences.getInstance();
  final current = sp.getInt('registrosEnviadosTotales') ?? 0;
  final updated = current + 1;
  await sp.setInt('registrosEnviadosTotales', updated);
}
