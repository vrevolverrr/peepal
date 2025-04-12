import 'package:logging/logging.dart';
import 'package:peepal/client/base.dart';
import 'package:peepal/client/toilets/model/latlng.dart';

final class PPToiletApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPToiletApi');

  @override
  final String endpoint = "/api/toilets";

  PPToiletApi({required super.dio});

  Future<void> createToilet({
    required String name,
    required String address,
    required PPLatLng location,
    bool? handicapAvail,
    bool? bidetAvail,
    bool? showerAvail,
    bool? sanitiserAvail,
  }) async {
    try {
      await dio.post('$endpoint/create', data: {
        'name': name,
        'address': address,
        'location': location.toJson(),
        if (handicapAvail != null) 'handicapAvail': handicapAvail,
        if (bidetAvail != null) 'bidetAvail': bidetAvail,
        if (showerAvail != null) 'showerAvail': showerAvail,
        if (sanitiserAvail != null) 'sanitiserAvail': sanitiserAvail,
      });
    } catch (e) {
      logger.severe('Failed to create toilet: $e');
      rethrow;
    }
  }
}
