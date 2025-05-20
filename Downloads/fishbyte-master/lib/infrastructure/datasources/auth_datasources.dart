// DEPRECATED: Este archivo y sus clases han sido reemplazados por la integración con Supabase
// Ahora se usa AuthRepository con Supabase en lugar de AuthDataSource con GraphQL
// Se mantiene este archivo para compatibilidad con código antiguo que aún no ha sido migrado

import 'package:fishbyte/infrastructure/graphql/auth_queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthDataSource {
  final GraphQLClient client;

  AuthDataSource(this.client);

  // Esta función ha sido reemplazada por la implementación en AuthRepository con Supabase
  Future<Map<String, dynamic>> fetchUserData() async {
    print("ADVERTENCIA: AuthDataSource.fetchUserData está obsoleto. Usa AuthRepository con Supabase.");
    
    final QueryOptions options = QueryOptions(
      document: gql(meQuery),
    );

    final result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final meData = result.data!['me'];
    final centersData = result.data!['centers'];

    return {
      'enterprise': meData['enterprise'], // Ajustar al formato esperado
      'centers': centersData['data'],     // Ajustar al formato esperado
      'role': meData['role'],             // Ajustar al formato esperado
    };
  }
}
