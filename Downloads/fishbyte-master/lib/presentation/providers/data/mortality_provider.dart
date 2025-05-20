import 'package:fishbyte/infrastructure/repositories/mortalidades_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final mortalityRepositoryProvider = Provider((ref) => MortalityRepository());

// Usamos DateTime para manejar año y mes
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime(2024, 1)); // Enero 2024 por defecto

final mortalityDataProvider = Provider<List<int>>((ref) {
  final repository = ref.watch(mortalityRepositoryProvider);
  final selectedDate = ref.watch(selectedMonthProvider);
  final data = repository.getMonthlyData(selectedDate);
  
  if (data.isEmpty) {
    return List.filled(DateTime(selectedDate.year, selectedDate.month + 1, 0).day, 0);
  }
  return data;
});