import 'dart:math';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:dio/dio.dart';
import '../../utils/error_handler.dart';
import '../../utils/request_formatter.dart';

class InvestingApi {
  final router = Router();
  final dio = Dio();

  static const String baseUrl = 'https://api.investing.com/api';
  static final Map<String, String> headers = {
    'User-Agent': _generateRandomString(16),
    'Accept': 'application/json, text/plain, */*',
    'Origin': 'https://tr.investing.com',
    'Referer': 'https://tr.investing.com/',
    'domain-id': 'tr',
    'Host': 'api.investing.com',
    'Content-Length': '0',
    'x-requested-with': 'XMLHttpRequest',  
    'Connection': 'keep-alive',
    'x-write-key': _generateRandomString(16),
    // 'Content-Type': 'application/x-www-form-urlencoded',
    // 'Accept-Encoding': 'gzip, deflate, br, zstd',
    // 'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
    // 'Referrer-Policy': 'strict-origin-when-cross-origin',
    // 'Sec-Fetch-Dest': 'empty',
    // 'Sec-Fetch-Mode': 'cors',
    // 'Sec-Fetch-Site': 'same-origin',
    // 'sec-ch-ua': 'Google Chrome: v=105, Brand:v=8, Chromium:v=105,
    // 'sec-ch-ua-mobile': '?0',
    // 'sec-ch-ua-platform': 'Windows',
    // 'pragma': 'no-cache',
    // 'cache-control': 'no-cache',
    // 'authority': 'www.investing.com',     
    // 'method': 'POST',     
    // 'scheme': 'https',
  };

  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  InvestingApi() {
    router.get('/<path|.*>', _handleRequest);
  }

  Future<shelf.Response> _handleRequest(shelf.Request request, String path) async {
    try {
      final response = await dio.get(
        '$baseUrl/$path',
        queryParameters: request.url.queryParameters,
        options: Options(headers: headers),
      );

      return shelf.Response.ok(
        RequestFormatter.formatResponse(response.data),
        headers: {'Content-Type': 'application/json'}
      );
    } catch (e) {
      return ErrorHandler.handle(e, request, path);
    }
  }
}