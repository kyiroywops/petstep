import 'package:fishbyte/infrastructure/models/center_data_model.dart';
import 'package:fishbyte/infrastructure/models/user_model.dart';


class AuthState {
  final bool loading;
  final String? backendUrl;
  final String? jwt;
  final User? user;
  final List<CenterModel>? centers;
  final String? error;

  AuthState({
    required this.loading,
    this.backendUrl,
    this.jwt,
    this.user,
    this.centers,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      loading: true,
      backendUrl: null,
      jwt: null,
      user: null,
      centers: null,
      error: null,
    );
  }

  AuthState copyWith({
    bool? loading,
    String? backendUrl,
    String? jwt,
    User? user,
    List<CenterModel>? centers,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      backendUrl: backendUrl ?? this.backendUrl,
      jwt: jwt ?? this.jwt,
      user: user ?? this.user,
      centers: centers ?? this.centers,
      error: error ?? this.error,
    );
  }
}
