import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recentlySentProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final sp = await SharedPreferences.getInstance();
  final raw = sp.getString('recentlySentReports') ?? '[]';
  final List<dynamic> list = json.decode(raw);
  return list.cast<Map<String, dynamic>>();
});
