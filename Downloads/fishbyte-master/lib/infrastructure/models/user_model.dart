import 'package:fishbyte/infrastructure/models/role_model.dart';


class User {
  final int id;
  final String username;
  final String email;
  final Role role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: Role.fromJson(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.toJson(),
    };
  }
}
