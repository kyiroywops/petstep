// models/image_report.dart

class ImageReport {
  final int? id;            // PK autoincrement
  final String localReportId; // Relación con LocalReport.idGlobal
  final String path;        // Ruta local en el filesystem
  final String stepName;    // "Imagen General", "Branquias", etc.

  ImageReport({
    this.id,
    required this.localReportId,
    required this.path,
    required this.stepName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'localReportId': localReportId,
      'path': path,
      'stepName': stepName,
    };
  }

  factory ImageReport.fromMap(Map<String, dynamic> map) {
    return ImageReport(
      id: map['id'],
      localReportId: map['localReportId'],
      path: map['path'] ?? '',
      stepName: map['stepName'] ?? '',
    );
  }
}
