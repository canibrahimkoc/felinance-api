import 'dart:convert';

class RequestFormatter {
  static String formatResponse(dynamic data) {
    return JsonEncoder.withIndent('  ').convert(data);
  }

  static Map<String, dynamic> formatQueryParameters(Map<String, String> queryParams) {
    return queryParams.map((key, value) {
      try {
        return MapEntry(key, json.decode(value));
      } catch (_) {
        if (value.contains(',')) {
          return MapEntry(key, value.split(','));
        }
        if (int.tryParse(value) != null) {
          return MapEntry(key, int.parse(value));
        }
        if (double.tryParse(value) != null) {
          return MapEntry(key, double.parse(value));
        }
        return MapEntry(key, value);
      }
    });
  }
}