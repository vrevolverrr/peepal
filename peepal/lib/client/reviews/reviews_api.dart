import 'package:logging/logging.dart';
import 'package:peepal/client/base.dart';

class PPReviewsApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPReviewsApi');

  @override
  final String endpoint = "/api/reviews";

  PPReviewsApi({required super.dio});
}
