import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fishbyte/presentation/providers/reports_provider.dart';

/// Calcula cuántos LocalReport tienen status="readyToUpload".
final pendingReportsCountProvider = Provider<int>((ref) {
  final asyncReports = ref.watch(allReportsProvider);

  // Si no están cargados o hay error, retornamos 0
  return asyncReports.maybeWhen(
    data: (list) => list.where((r) => r.status == 'readyToUpload').length,
    orElse: () => 0,
  );
});