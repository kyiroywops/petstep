import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fishbyte/infrastructure/models/local_report.dart';

/// Guarda el último LocalReport COMPLETADO
/// para poder "reutilizar" algunos campos (center, cage, enterprise, user, etc.)
final lastFinishedReportProvider = StateProvider<LocalReport?>((ref) {
  return null;
});
