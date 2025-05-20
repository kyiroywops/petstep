// DEPRECATED: Este archivo y sus providers han sido reemplazados por la integración con Supabase
// Ahora se usa auth_provider.dart con supabaseClientProvider y authRepositoryProvider
// Se mantiene este archivo para compatibilidad con código antiguo que aún no ha sido migrado

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fishbyte/infrastructure/datasources/auth_datasources.dart';
import 'package:fishbyte/presentation/providers/graphql_client_provider.dart';

final authDataSourceProvider = Provider<dynamic>((ref) {
  print("ADVERTENCIA: authDataSourceProvider está obsoleto. Usa authRepositoryProvider de auth_provider.dart");
  return null;
});
