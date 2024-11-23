import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';  
import '../../utils/error_handler.dart';

class YFinanceApi {
  final router = Router();

  static const String scriptPath = 'cross/yfinance/yfinance_service.py';
  static const String venvPythonPath = 'venv/bin/python3.11';

  YFinanceApi() {
    router.get('/<path|.*>', _handleRequest);
  }

  Future<shelf.Response> _handleRequest(shelf.Request request, String path) async {
    try {
      // Python yolu oluşturuluyor
      final pythonPath = File(venvPythonPath).absolute.path;

      final result = await Process.run(pythonPath, [
        scriptPath,
        path,
      ]);

      if (result.exitCode != 0) {
        throw Exception('Python script error: ${result.stderr}');
      }

      return shelf.Response.ok(
        result.stdout,
        headers: {'Content-Type': 'application/json'}
      );
    } catch (e) {
      return ErrorHandler.handle(e, request, path);
    }
  }
}
