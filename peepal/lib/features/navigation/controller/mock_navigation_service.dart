import 'package:peepal/features/toilet_map/model/toilet_location.dart';

class MockNavigationService {
  Future<Map<String, dynamic>> getNavigationDirections({
    required ToiletLocation destination,
    required double currentLatitude,
    required double currentLongitude,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock data
    return {
      "overview_polyline": "mvcG{nbxRM_BI_@Y?[AQIOMGS@UFOPMTKGUCKMQ[Ti@MUEMJMFSBYCMOEMGoA?EGCOI",
      "start_address": "Japanese Garden Rd, Singapore",
      "end_address": "1 Chinese Garden Rd, Singapore 619795",
      "start_location": {
        "lat": 1.3349539,
        "lng": 103.7286225
      },
      "end_location": {
        "lat": 1.3365222,
        "lng": 103.7306099
      },
      "distance": "0.4 km",
      "duration": "6 mins",
      "directions": [
        {
          "distance": "72 m",
          "duration": "1 min",
          "polyline": "mvcG{nbxRC]Cc@AOCMI_@",
          "start_location": {
            "lat": 1.3349539,
            "lng": 103.7286225
          },
          "end_location": {
            "lat": 1.3350664,
            "lng": 103.7292624
          },
          "instructions": "Head east on Japanese Garden Rd"
        },
        {
          "distance": "0.1 km",
          "duration": "2 mins",
          "polyline": "ewcG{rbxRY?Q?IAICGEKECGEKAG?I@KBKBCDEJGTK",
          "start_location": {
            "lat": 1.3350664,
            "lng": 103.7292624
          },
          "end_location": {
            "lat": 1.3352986,
            "lng": 103.7298063
          },
          "instructions": "Turn left"
        },
        {
          "distance": "33 m",
          "duration": "1 min",
          "polyline": "sxcGivbxRGUAGACMQ",
          "start_location": {
            "lat": 1.3352986,
            "lng": 103.7298063
          },
          "end_location": {
            "lat": 1.3354258,
            "lng": 103.7300672
          },
          "instructions": "Turn left"
        },
        {
          "distance": "20 m",
          "duration": "1 min",
          "polyline": "mycG}wbxR[T",
          "start_location": {
            "lat": 1.3354258,
            "lng": 103.7300672
          },
          "end_location": {
            "lat": 1.3355742,
            "lng": 103.7299639
          },
          "instructions": "Turn left"
        },
        {
          "distance": "37 m",
          "duration": "1 min",
          "polyline": "izcGgwbxRSCUIMAGC",
          "start_location": {
            "lat": 1.3355742,
            "lng": 103.7299639
          },
          "end_location": {
            "lat": 1.3358864,
            "lng": 103.7300616
          },
          "instructions": "Turn right"
        },
        {
          "distance": "0.1 km",
          "duration": "2 mins",
          "polyline": "i|cG{wbxRGFEBEBGBIBI?G?G?GCA?GGEGEG?EAI?UAUCY?E",
          "start_location": {
            "lat": 1.3358864,
            "lng": 103.7300616
          },
          "end_location": {
            "lat": 1.3364046,
            "lng": 103.7305442
          },
          "instructions": "Turn left"
        },
        {
          "distance": "15 m",
          "duration": "1 min",
          "polyline": "o_dG{zbxRGCOI",
          "start_location": {
            "lat": 1.3364046,
            "lng": 103.7305442
          },
          "end_location": {
            "lat": 1.3365222,
            "lng": 103.7306099
          },
          "instructions": "Turn left"
        }
      ]
    };
  }
}