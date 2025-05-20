import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers para email y password que pueden ser utilizados por otros componentes
// pero no son necesarios para la autenticación con Supabase/Google
final emailProvider = StateProvider<String>((ref) => "");
final passwordProvider = StateProvider<String>((ref) => "");

// El authRepositoryProvider ha sido movido a auth_provider.dart
// y ahora usa Supabase en lugar de GraphQL
