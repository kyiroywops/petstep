class Role {
  final String name;
  final String description;

  Role({
    required this.name,
    required this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
