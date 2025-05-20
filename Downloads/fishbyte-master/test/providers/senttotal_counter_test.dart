import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fishbyte/presentation/providers/senttotal_counter_provider.dart';

void main() {
  setUp(() async {
    // Configurar SharedPreferences para testing
    SharedPreferences.setMockInitialValues({});
  });

  test('El contador debe iniciar en cero', () async {
    final container = ProviderContainer();
    final value = await container.read(sentCounterProvider.future);
    expect(value, 0);
  });

  test('incrementSentCounter debe aumentar el contador en 1', () async {
    // Incrementar el contador
    await incrementSentCounter();
    
    // Verificar que el valor aumentó
    final sp = await SharedPreferences.getInstance();
    expect(sp.getInt('registrosEnviadosTotales'), 1);
  });
}