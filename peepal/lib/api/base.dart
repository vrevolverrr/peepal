import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

abstract class PPApiClient {
  Logger get logger;
  String get endpoint;

  final Dio dio;

  PPApiClient({required this.dio});
}
