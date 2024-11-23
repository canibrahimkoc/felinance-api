import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:dio/dio.dart';

class ErrorHandler {
  static shelf.Response handle(dynamic e, shelf.Request request, String path) {
    if (e is DioException) {
      return _handleDioError(e, request, path);
    } else {
      return shelf.Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal Server Error',
          'message': e.toString(),
          'path': path,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  static shelf.Response _handleDioError(DioException e, shelf.Request request, String path) {
    final statusCode = e.response?.statusCode ?? 500;
    final errorResponse = {
      'status': statusCode,
      'error': _formatDioErrorData(e),
      'origin_url': '${request.url}',
      'request_url': '${e.requestOptions.baseUrl}${e.requestOptions.path}',
      'parameters': request.url.queryParameters,
      'error_info': _formatDioError(e),
    };

    return shelf.Response(
      statusCode,
      body: JsonEncoder.withIndent('  ').convert(errorResponse),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static String _formatDioError(DioException e) {
    return 'DioException [${e.type}]: ${e.message}';
  }

  static String _formatDioErrorData(DioException e) {
    if (e.response?.data == null) return '';
    
    if (e.response!.data is Map) {
      final errors = e.response!.data['@errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      }
    }
    
    return e.response!.data.toString();
  }
}