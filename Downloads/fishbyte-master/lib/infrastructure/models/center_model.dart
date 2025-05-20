// este solamente es el model para seleccionar el center

class Center {
  final String label;
  final String value;

  Center({required this.label, required this.value});

  factory Center.fromJson(Map<String, dynamic> json) {
    return Center(
      label: json['label'],
      value: json['value'],
    );
  }
}
