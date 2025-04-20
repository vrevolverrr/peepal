import 'package:dio/dio.dart';

/// Logging utilities for debugging and monitoring
import 'package:logging/logging.dart';

/// Base class for all PeePal API clients.
///
/// Provides common functionality for making HTTP requests and handling responses.
/// All specific API clients (toilets, reviews, etc.) should extend this class.
abstract class PPApiClient {
  /// Logger instance for this API client.
  ///
  /// Used for debugging and monitoring API operations.
  Logger get logger;

  /// Base endpoint URL for this API client's requests.
  ///
  /// Example: '/api/v1/toilets' for the toilets API.
  String get endpoint;

  /// HTTP client for making API requests.
  ///
  /// Configured with base URL and default headers.
  final Dio dio;

  /// Creates a new API client with the given HTTP client.
  ///
  /// [dio] must be configured with appropriate base URL and headers.
  PPApiClient({required this.dio});
}
