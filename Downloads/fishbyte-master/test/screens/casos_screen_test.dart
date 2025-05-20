import 'package:fishbyte/presentation/widgets/casos_screen/recentlysent_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishbyte/presentation/screens/casos_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  testWidgets('FishPhotoSessionSetupScreen shows main elements', (WidgetTester tester) async {
    // Construir el widget
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const FishPhotoSessionSetupScreen(),
        ),
      ),
    );
    
    // Esperar frame inicial
    await tester.pump();

    // Verificar que los elementos principales estén presentes
    expect(find.text('Registrar nuevo caso'), findsOneWidget);
    expect(find.byType(RecentlySentWidget), findsOneWidget);
  });

  testWidgets('Pull to refresh gesture is recognized', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const FishPhotoSessionSetupScreen(),
        ),
      ),
    );

    // Esperar frame inicial
    await tester.pump();

    // Encontrar el SmartRefresher
    final finder = find.byType(SmartRefresher);
    expect(finder, findsOneWidget);

    // Simular el gesto de pull to refresh
    await tester.drag(finder, const Offset(0, 300));
    await tester.pump();
  });
}