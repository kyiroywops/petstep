// user_id_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lee el userData de SharedPreferences y retorna el ID como int.
/// Si no existe o hay error, retorna 0.
final userIdProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userDataString = prefs.getString('userData');
  if (userDataString == null) {
    return 0; 
  }

  final Map<String, dynamic> userJson = jsonDecode(userDataString);
  final idStr = userJson['id'];
  if (idStr == null) return 0;

  // Convertirlo a int
  return int.tryParse(idStr) ?? 0;
});
