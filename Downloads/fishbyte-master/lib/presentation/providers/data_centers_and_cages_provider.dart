import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fishbyte/infrastructure/models/center_data_model.dart';

/// Carga la lista de centros desde SharedPreferences, parseando tu JSON real.
final centersFutureProvider = FutureProvider<List<CenterModel>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final centersDataString = prefs.getString('centersData');
  if (centersDataString == null) {
    return [];
  }

  final List<dynamic> decoded = jsonDecode(centersDataString);
  return decoded.map((json) => CenterModel.fromJson(json)).toList();
});

final selectedCenterIndexProvider = StateProvider<int>((ref) => 0);
final selectedCageIndexProvider = StateProvider<int>((ref) => 0);
