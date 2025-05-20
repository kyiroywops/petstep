import 'package:intl/intl.dart';

class MortalityRepository {
  // Modificamos las claves para usar minúsculas consistentes
final Map<String, List<int>> _mockData = {
  '2024-enero': [8, 3, 6, 2, 9, 7, 4, 5, 6, 3, 7, 1, 2, 4, 5, 6, 2, 3, 9, 4, 1, 7, 8, 2, 3, 5, 6, 4, 1, 0, 3],
  '2023-diciembre': [6, 4, 2, 8, 5, 1, 7, 3, 4, 6, 2, 1, 0, 5, 3, 6, 8, 2, 1, 4, 7, 6, 3, 2, 0, 4, 5, 3, 6, 1, 2],
};

  List<int> getMonthlyData(DateTime date) {
    final key = '${date.year}-${_getMonthName(date)}'.toLowerCase(); // Aseguramos minúsculas
    return _mockData[key] ?? [];
  }

  String _getMonthName(DateTime date) {
    return DateFormat('MMMM', 'es_ES').format(date).toLowerCase(); // Convertimos a minúsculas
  }
}