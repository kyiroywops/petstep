// este simplemente es para seleccionar el enterprise en el login

class Enterprise {
  final String name;
  final String nickname;

  Enterprise({
    required this.name,
    required this.nickname,
  });

  factory Enterprise.fromJson(Map<String, dynamic> json) {
    return Enterprise(
      name: json['name'],
      nickname: json['nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nickname': nickname,
    };
  }
}
