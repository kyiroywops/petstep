// DEPRECATED: Este archivo y sus providers han sido reemplazados por la integración con Supabase
// Ahora se usa auth_provider.dart con supabaseClientProvider
// Se mantiene este archivo para compatibilidad con código antiguo que aún no ha sido migrado

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fishbyte/presentation/providers/login/centers_provider.dart';

// Esta función ha sido reemplazada por el cliente Supabase
Future<GraphQLClient> createGraphQLClient(String enterpriseUrl) async {
  print("ADVERTENCIA: createGraphQLClient está obsoleto. Usa supabaseClientProvider.");
  print("createGraphQLClient: enterpriseUrl = $enterpriseUrl");

  final httpLink = HttpLink('$enterpriseUrl/graphql');
  
  print("HTTP Link: ${httpLink.uri}");

 final authLink = AuthLink(
  getToken: () async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    if (token == null) {
      print("Advertencia: El token aún no está disponible");
    }
    return token != null ? 'Bearer $token' : '';
  },
);

final errorLink = ErrorLink(
  onGraphQLError: (request, forward, response) {
    print("[GraphQL Error - Request]: $request");
    for (final error in response.errors!) {
      print('[GraphQL error]: ${error.message}');
    }
    return forward != null ? forward(request) : null; // Reintentar si es posible
  },
  onException: (request, forward, exception) {
    print('[Network error]: $exception');
    // Reintentar en caso de errores transitorios
    if (exception.toString().contains('TimeoutException') ||
        exception.toString().contains('SocketException')) {
      print('Reintentando...');
      return forward != null ? forward(request) : null;
    }
    return null;
  },
);

  final link = Link.from([
    errorLink,
    authLink,
    httpLink,
  ]);

  final client = GraphQLClient(
    link: link,
    cache: GraphQLCache(),
  );

  print("GraphQLClient creado con éxito");
  return client;
}

// Provider obsoleto. Usar supabaseClientProvider de auth_provider.dart
final graphQLClientProvider = FutureProvider<GraphQLClient?>((ref) async {
  print("ADVERTENCIA: graphQLClientProvider está obsoleto. Usa supabaseClientProvider.");
  final enterpriseUrl = ref.watch(selectedCenterValueProvider);
  print("Valor actual de enterpriseUrl en graphQLClientProvider: $enterpriseUrl");
  
  if (enterpriseUrl == null || !enterpriseUrl.startsWith('http')) {
    print("Error: enterpriseUrl no es válido");
    return null;
  }

  // Añadimos un pequeño delay para asegurar que el token esté disponible
  final prefs = await SharedPreferences.getInstance();
  int attempts = 0;
  while (attempts < 3) {
    final token = prefs.getString('jwt');
    if (token != null) {
      break;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    attempts++;
  }

  return createGraphQLClient(enterpriseUrl);
});
