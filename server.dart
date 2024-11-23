import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'cross/investing/investing_api.dart';
import 'cross/yfinance/yfinance_api.dart';

class Config {
  static const int port = 8888;
  // static const int host = 0.0.0.0;
}
// Server
void main() async {
  final app = Router();

  // Add a route for the root path and /api
  app.get('/', (request) => shelf.Response.ok('Server running...'));
  app.get('/api', (request) => shelf.Response.ok('Server running...'));

  // Register API routes
  app.mount('/api/investing', InvestingApi().router);
  app.mount('/api/yfinance', YFinanceApi().router);

  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(app);
      
  final server = await io.serve(handler, InternetAddress.anyIPv4, Config.port);
  print('Server running on http://${server.address.host}:${server.port}');
}
