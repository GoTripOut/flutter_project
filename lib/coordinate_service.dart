import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RestApiService {
  String? restApiKey = dotenv.env['KAKAO_REST_KEY'];

  // 좌표 받아오기
  Future<LatLng?> getCoordinates(String query) async {
    if (restApiKey == null) {
      print("KAKAO_REST_KEY가 .env에서 로드되지 않았습니다.");
    }

    final url = Uri.https("dapi.kakao.com", "/v2/local/search/address.json", {
      "query": query,
      "analyze_type": "similar",
    });
    final response = await http.get(url, headers: {
      "Authorization": "KakaoAK $restApiKey",
      "Content-Type": "application/json;charset=UTF-8",
    });

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body["documents"].isNotEmpty) {
        final location = body["documents"][0];
        print("입력받은 지역의 위치는 $location");
        double lat = double.parse(location['y']);
        double lng = double.parse(location['x']);
        return LatLng(lat, lng);
      }
    }
    else {
      print("카카오 API 요청 실패 ${response.statusCode}");
    }
    return null;
  }

  // 카카오내비 API를 활용하여 다중 경유지 길찾기
  Future<dynamic> findRoute(List<LatLng> poiLat) async {
    if (restApiKey == null) {
      print("KAKAO_REST_KEY가 .env에서 로드되지 않았습니다.");
    }

    // 출발지와 목적지를 제외한 경유지
    List<Map<String, dynamic>> waypoints = [];

    if (poiLat.length >= 3) {
      for (int i = 1; i < poiLat.length - 1; i++) {
        waypoints.add({
          "name": "$i번째 경유지",
          "x": poiLat[i].longitude,
          "y": poiLat[i].latitude,
        });
      }
    }

    final Uri url = Uri.parse("https://apis-navi.kakaomobility.com/v1/waypoints/directions");
    final Map<String, dynamic> request = {
      "origin": {
        "x": poiLat[0].longitude,
        "y": poiLat[0].latitude,
      },
      "destination": {
        "x": poiLat[poiLat.length - 1].longitude,
        "y": poiLat[poiLat.length - 1].latitude,
      },
      "waypoints": waypoints,
      "priority": "DISTANCE", // 경로 탐색 기준
      "road_details": true,
      "car_hipass": true,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "KakaoAK $restApiKey",
          "Content-Type": "application/json;charset=UTF-8"},
        body: jsonEncode(request),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body;
      }
      else {
        print("response.statusCode : ${response.statusCode}");
        return null;
      }
    }
    catch(e) {
      print("카카오내비 API 요청 실패 $e");
    }
  }
}