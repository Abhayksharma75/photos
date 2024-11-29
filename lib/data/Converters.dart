import 'dart:convert'; 

class Converters {
  static List<double>? fromString(String? value) {
    if (value == null) {
      return null;
    }
    return List<double>.from(jsonDecode(value).map((x) => (x as num).toDouble()));
  }

  static String fromFloatArray(List<double> array) {
    return jsonEncode(array);
  }
}
