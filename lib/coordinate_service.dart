import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RestApiService {
  String? RestApiKey = dotenv.env['KAKAO_REST_KEY'];

  // 좌표 받아오기
  Future<LatLng?> getCoordinates(String query) async {
    if (RestApiKey == null) {
      print("KAKAO_REST_KEY가 .env에서 로드되지 않았습니다.");
    }

    final url = Uri.https("dapi.kakao.com", "/v2/local/search/address.json", {
      "query": query,
      "analyze_type": "similar",
    });
    final response = await http.get(url, headers: {
      "Authorization": "KakaoAK $RestApiKey",
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
}