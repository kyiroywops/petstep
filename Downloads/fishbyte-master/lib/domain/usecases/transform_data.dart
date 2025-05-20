import 'package:fishbyte/infrastructure/models/center_data_model.dart';


List<CenterModel> transformCenters(Map<String, dynamic> rawCenters) {
  return (rawCenters['data'] as List)
      .map((centerData) => CenterModel.fromJson(centerData['attributes']))
      .toList();
}
